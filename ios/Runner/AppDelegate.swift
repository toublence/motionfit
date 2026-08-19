import FirebaseCore
import Flutter
import UIKit
import UserNotifications
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var legacyStorageChannel: FlutterMethodChannel?
  private var legacyStorageReader: LegacyCapacitorStorageReader?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    // Required by flutter_local_notifications so scheduled local notifications
    // are handled (including while the app is in the foreground).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "LegacyCapacitorStorage"
    ) else { return }
    let channel = FlutterMethodChannel(
      name: "fit.motionfit.app/legacy_capacitor_storage",
      binaryMessenger: registrar.messenger()
    )
    legacyStorageChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "readAllValues" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let reader = LegacyCapacitorStorageReader()
      self?.legacyStorageReader = reader
      reader.read { [weak self] values, error in
        self?.legacyStorageReader = nil
        if let error {
          result(FlutterError(
            code: "legacy_storage_read_failed",
            message: error.localizedDescription,
            details: nil
          ))
        } else {
          result(values ?? [:])
        }
      }
    }
  }
}

private final class LegacyCapacitorStorageReader: NSObject, WKNavigationDelegate {
  private var webView: WKWebView?
  private var completion: (([String: String]?, Error?) -> Void)?
  private var timeout: DispatchWorkItem?

  func read(completion: @escaping ([String: String]?, Error?) -> Void) {
    self.completion = completion
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .default()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    self.webView = webView
    webView.navigationDelegate = self

    let timeout = DispatchWorkItem { [weak self] in
      self?.finish(
        values: nil,
        error: NSError(
          domain: "fit.motionfit.app.legacy-storage",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Legacy localStorage read timed out"]
        )
      )
    }
    self.timeout = timeout
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: timeout)

    // Capacitor's default iOS origin was capacitor://localhost. The default
    // WKWebsiteDataStore keeps that origin's localStorage across an app update.
    webView.loadHTMLString(
      "<html><head></head><body></body></html>",
      baseURL: URL(string: "capacitor://localhost")
    )
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let script = """
      (() => {
        const result = {};
        for (let index = 0; index < window.localStorage.length; index += 1) {
          const key = window.localStorage.key(index);
          if (key === null) continue;
          const value = window.localStorage.getItem(key);
          if (value !== null) result[key] = value;
        }
        return JSON.stringify(result);
      })()
      """
    webView.evaluateJavaScript(script) { [weak self] value, error in
      if let error {
        self?.finish(values: nil, error: error)
        return
      }
      guard
        let source = value as? String,
        let data = source.data(using: .utf8),
        let object = try? JSONSerialization.jsonObject(with: data),
        let values = object as? [String: String]
      else {
        self?.finish(values: [:], error: nil)
        return
      }
      self?.finish(values: values, error: nil)
    }
  }

  private func finish(values: [String: String]?, error: Error?) {
    guard let completion else { return }
    self.completion = nil
    timeout?.cancel()
    timeout = nil
    webView?.navigationDelegate = nil
    webView?.stopLoading()
    webView = nil
    completion(values, error)
  }
}

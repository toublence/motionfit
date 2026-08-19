package fit.motionfit.app

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val legacyStorageChannel = "fit.motionfit.app/legacy_capacitor_storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, legacyStorageChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "readAllValues") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                runOnUiThread {
                    readLegacyLocalStorage(result)
                }
            }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun readLegacyLocalStorage(result: MethodChannel.Result) {
        val webView = WebView(this)
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        val handler = Handler(Looper.getMainLooper())
        var completed = false

        fun finish(values: Map<String, String>?, error: Throwable? = null) {
            if (completed) return
            completed = true
            handler.removeCallbacksAndMessages(null)
            webView.stopLoading()
            webView.destroy()
            if (error != null) {
                result.error("legacy_storage_read_failed", error.message, null)
            } else {
                result.success(values ?: emptyMap<String, String>())
            }
        }

        handler.postDelayed({
            finish(null, IllegalStateException("Legacy localStorage read timed out"))
        }, 5_000)

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                val script = """
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
                """.trimIndent()
                view.evaluateJavascript(script) { encoded ->
                    try {
                        val decoded = JSONArray("[$encoded]").getString(0)
                        val json = JSONObject(decoded)
                        val values = mutableMapOf<String, String>()
                        val names = json.keys()
                        while (names.hasNext()) {
                            val key = names.next()
                            values[key] = json.getString(key)
                        }
                        finish(values)
                    } catch (error: Throwable) {
                        finish(null, error)
                    }
                }
            }
        }
        // Capacitor's default Android origin for this app was https://localhost.
        // Loading a tiny document at that origin exposes the preserved WebView
        // localStorage without bundling or executing the retired app.
        webView.loadDataWithBaseURL(
            "https://localhost",
            "<html><head></head><body></body></html>",
            "text/html",
            "UTF-8",
            null,
        )
    }
}

import CoreVideo
import Flutter
import Foundation

final class MotionfitPoseTexture: NSObject, FlutterTexture {
  private let lock = NSLock()
  private var latestPixelBuffer: CVPixelBuffer?

  func update(with pixelBuffer: CVPixelBuffer) {
    lock.lock()
    latestPixelBuffer = pixelBuffer
    lock.unlock()
  }

  func clear() {
    lock.lock()
    latestPixelBuffer = nil
    lock.unlock()
  }

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    lock.lock()
    let pixelBuffer = latestPixelBuffer
    lock.unlock()

    guard let pixelBuffer else { return nil }
    return Unmanaged.passRetained(pixelBuffer)
  }

  func onTextureUnregistered(_ texture: FlutterTexture) {
    clear()
  }
}

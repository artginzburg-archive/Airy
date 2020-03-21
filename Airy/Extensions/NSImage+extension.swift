import Cocoa

extension NSImage {

  func trim(_ rect: CGRect) -> NSImage {
      let result = NSImage(size: rect.size)
      result.lockFocus()

      let destRect = CGRect(origin: .zero, size: result.size)
      draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)

      result.unlockFocus()
      return result
  }

}

import Cocoa

extension NSApplication {
  var isLeftMouseDown: Bool { currentEvent?.type == .leftMouseDown }
  var isOptionKeyDown: Bool { NSEvent.modifierFlags.contains(.option) }
  var isShiftKeyDown: Bool { NSEvent.modifierFlags.contains(.shift) }
  
  func terminateAnimated(_ sender: Any?, _ statusItem: NSStatusItem = statusItem, _ initialLength: CGFloat = initialSquareLength) {
    if isOptionKeyDown {
      terminate(sender)
    } else {
      statusItem.button?.fade(0, 0.25)
      
      statusItem.length = initialLength
      
      Timer.new(every: 10.millisecond) {
        if statusItem.length <= 1 {
          self.terminate(sender)
        } else {
          statusItem.length -= statusItem.length / initialLength * 2.5
        }
      }.start()
    }
  }
  
  func animateStatusItemWake(_ statusItem: NSStatusItem = statusItem, _ initialLength: CGFloat = initialSquareLength) {
    if isShiftKeyDown { return }
    
    statusItem.length = 1

    Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
      if statusItem.length >= initialLength - 1 {
        statusItem.length = initialLength
        timer.invalidate()
      } else {
        statusItem.length += (initialLength / (initialLength / 2) - (statusItem.length / initialLength * 2))
      }
    }
  }
}

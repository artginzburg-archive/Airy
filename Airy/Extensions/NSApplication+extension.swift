import Cocoa

extension NSApplication {
  var isLeftMouseDown: Bool { currentEvent?.type == .leftMouseDown }
  var isOptionKeyDown: Bool { NSEvent.modifierFlags.contains(.option) }
  var isShiftKeyDown: Bool { NSEvent.modifierFlags.contains(.shift) }
  
  func terminateAnimated(_ sender: Any?) {
    if isOptionKeyDown {
      terminate(sender)
    } else {
      statusItem.button?.fade(0, 0.25)
      
      statusItem.length = initialSquareLength
      
      Timer.new(every: 10.millisecond) {
        statusItem.length -= statusItem.length / initialSquareLength * 2.5
        if statusItem.length <= 1 {
          self.terminate(sender)
        }
      }.start()
    }
  }
}

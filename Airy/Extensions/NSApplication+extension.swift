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
  
  func animateStatusItemWake() {
    if isShiftKeyDown { return }
    
    statusItem.length = 1

    Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
      if statusItem.length >= initialSquareLength - 1 {
        statusItem.length = initialSquareLength
        timer.invalidate()
      } else {
        statusItem.length += (initialSquareLength / (initialSquareLength / 2) - (statusItem.length / initialSquareLength * 2))
      }
    }
  }
}

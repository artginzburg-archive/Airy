import Foundation
import Cocoa

@discardableResult
func shell(_ command: String) -> String {
  let task = Process()
  task.launchPath = "/bin/bash"
  task.arguments = ["-c", command]
  
  let pipe = Pipe()
  task.standardOutput = pipe
  task.launch()
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  
  return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
}

extension NSMenuItem {
  var isChecked: Bool {
    get { state == .on }
    set {
      state = newValue ? .on : .off
    }
  }
}

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

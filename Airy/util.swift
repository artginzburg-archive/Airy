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
}

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldHandleReopen(_ sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool
  {
    if let button = statusItem.button {
      button.performClick(NSApp.currentEvent)
      button.momentaryHighlight()
    }
    return true
  }
}

import Cocoa
import HotKey
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if Storage.fileExists("globalKeybind.json", in: .documents) {
      
      let globalKeybinds = Storage.retrieve("globalKeybind.json", from: .documents, as: GlobalKeybindPreferences.self)
      hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
    }
  }
  
  public var hotKey: HotKey? {
    didSet {
      guard let hotKey = hotKey else {
        return
      }
      
      hotKey.keyDownHandler = {
        if let button = statusItem.button {
          button.momentaryHighlight()
        }
        performAirpodsAction()
      }
    }
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool
  {
    if let button = statusItem.button {
      button.momentaryHighlight()
    }
    performAirpodsAction()
    return true
  }
  
}

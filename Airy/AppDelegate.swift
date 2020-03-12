import Cocoa
import HotKey
import Carbon

let isFirstLaunch = UserDefaults.isFirstLaunch

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if Storage.fileExists("globalKeybind.json", in: .documents) && !isFirstLaunch {
      let globalKeybinds = Storage.retrieve("globalKeybind.json", from: .documents, as: GlobalKeybindPreferences.self)
      hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
    }
  }
  
  private func airPodsAndHighlight() {
    statusItem.button!.momentaryHighlight()
    performAirpodsAction()
  }
  
  public var hotKey: HotKey? {
    didSet {
      guard let hotKey = hotKey else {
        return
      }
      
      hotKey.keyDownHandler = {
        self.airPodsAndHighlight()
      }
    }
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool
  {
    if NSApp.isShiftKeyDown {
      statusItem.button!.performClick(NSApp.currentEvent)
    } else {
      airPodsAndHighlight()
    }
    return true
  }
  
}

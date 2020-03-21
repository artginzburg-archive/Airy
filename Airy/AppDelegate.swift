import Cocoa
import HotKey
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if Storage.fileExists(Constants.globalKeybindFilename, in: .documents) && !Constants.isFirstLaunch {
      let globalKeybinds = Storage.retrieve(Constants.globalKeybindFilename, from: .documents, as: GlobalKeybindPreferences.self)
      hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKeybinds.keyCode, carbonModifiers: globalKeybinds.carbonFlags))
    }
  }
  
  public var escapeHotKey: HotKey? {
    didSet {
      guard let escapeHotKey = escapeHotKey else {
        return
      }
      
      escapeHotKey.isPaused = true
      
      escapeHotKey.keyDownHandler = {
        self.hotKey?.isPaused = true
        statusItem.button!.isHighlighted = false
      }
      
      escapeHotKey.keyUpHandler = {
        self.hotKey?.isPaused = false
        escapeHotKey.isPaused = true
      }
    }
  }
  
  public var hotKey: HotKey? {
    didSet {
      guard let hotKey = hotKey else {
        return
      }
      
      escapeHotKey = HotKey(carbonKeyCode: 53, carbonModifiers: hotKey.keyCombo.carbonModifiers)
      
      hotKey.keyDownHandler = {
        statusItem.button!.isHighlighted = true
        self.escapeHotKey?.isPaused = false
      }
      
      hotKey.keyUpHandler = {
        statusItem.button!.isHighlighted = false
        performAirpodsAction()
      }
    }
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool
  {
    if NSApp.isShiftKeyDown {
      statusItem.button!.performClick(NSApp.currentEvent)
    } else {
      statusItem.button!.momentaryHighlight()
      performAirpodsAction()
    }
    return true
  }
  
}

import Cocoa
import HotKey
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
      // Insert code here to initialize your application
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
//            [weak self] in
//              NSApplication.shared.orderedWindows.forEach({ (window) in
//                  if let mainWindow = window as? MainWindow {
//                      print("woo")
//                      NSApplication.shared.activate(ignoringOtherApps: true)
//                      mainWindow.makeKeyAndOrderFront(self)
//                      mainWindow.makeKey()
//                  }
//              })
            print("handled keydown")
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

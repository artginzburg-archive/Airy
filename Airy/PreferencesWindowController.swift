import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
  }
  
  @IBOutlet weak var prefViewCon: PreferencesViewController!
  
  override func keyDown(with event: NSEvent) {
    super.keyDown(with: event)
    print("keydown")
    if let vc = prefViewCon {
      print("let vc")
      if vc.listening {
        print("vc listening")
        vc.updateGlobalShortcut(event)
      }
    }
  }
  
  override func showWindow(_ sender: Any?) {
    NSApplication.shared.activate(ignoringOtherApps: true)
    window?.makeKeyAndOrderFront(self)
    window?.makeKey()
  }
}

import Cocoa

class PreferencesWindowController: NSWindowController {
  
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
  
}

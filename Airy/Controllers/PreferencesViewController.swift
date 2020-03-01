import Cocoa
import HotKey
import Carbon

class PreferencesViewController: NSViewController {
  
  @IBOutlet weak var clearButton: NSButton!
  @IBOutlet weak var shortcutButton: NSButton!
  
  @IBOutlet weak var setHotKeyButton: NSMenuItem!
  
  // When this boolean is true we will allow the user to set a new keybind.
  // We'll also trigger the button to highlight blue so the user sees feedback and knows the button is now active.
  var listening = false {
    didSet {
      if listening {
        DispatchQueue.main.async { [weak self] in
          self?.shortcutButton.highlight(true)
        }
      } else {
        DispatchQueue.main.async { [weak self] in
          self?.shortcutButton.highlight(false)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Check to see if the keybind has been stored previously
    // If it has then update the UI with the below methods.
    if Storage.fileExists("globalKeybind.json", in: .documents) {
      let globalKeybinds = Storage.retrieve("globalKeybind.json", from: .documents, as: GlobalKeybindPreferences.self)
      updateKeybindButton(globalKeybinds)
      updateClearButton(globalKeybinds)
    }
    
  }
  
  // When a shortcut has been pressed by the user, turn off listening so the window stops listening for keybinds
  // Put the shortcut into a JSON friendly struct and save it to storage
  // Update the shortcut button to show the new keybind
  // Make the clear button enabled to users can remove the shortcut
  // Finally, tell AppDelegate to start listening for the new keybind
  func updateGlobalShortcut(_ event : NSEvent) {
    self.listening = false
    
    if let characters = event.charactersIgnoringModifiers {
      let newGlobalKeybind = GlobalKeybindPreferences.init(
        function: event.modifierFlags.contains(.function),
        control: event.modifierFlags.contains(.control),
        command: event.modifierFlags.contains(.command),
        shift: event.modifierFlags.contains(.shift),
        option: event.modifierFlags.contains(.option),
        capsLock: event.modifierFlags.contains(.capsLock),
        carbonFlags: event.modifierFlags.carbonFlags,
        characters: characters,
        keyCode: UInt32(event.keyCode)
      )
      
      Storage.store(newGlobalKeybind, to: .documents, as: "globalKeybind.json")
      updateKeybindButton(newGlobalKeybind)
      clearButton.isEnabled = true
      let appDelegate = NSApplication.shared.delegate as! AppDelegate
      appDelegate.hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: UInt32(event.keyCode), carbonModifiers: event.modifierFlags.carbonFlags))
    }
    
  }
  
  // When the set shortcut button is pressed start listening for the new shortcut
  @IBAction func register(_ sender: Any) {
    unregister(nil)
    listening = true
    view.window?.makeFirstResponder(nil)
  }
  
  // If the shortcut is cleared, clear the UI and tell AppDelegate to stop listening to the previous keybind.
  @IBAction func unregister(_ sender: Any?) {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.hotKey = nil
    shortcutButton.title = ""
    setHotKeyButton.title = "Set HotKey"
    clearButton.isEnabled = false
    
    Storage.remove("globalKeybind.json", from: .documents)
  }
  
  // If a keybind is set, allow users to clear it by enabling the clear button.
  func updateClearButton(_ globalKeybindPreference : GlobalKeybindPreferences?) {
    if globalKeybindPreference != nil {
      clearButton.isEnabled = true
    } else {
      clearButton.isEnabled = false
    }
  }
  
  // Set the shortcut button to show the keys to press
  func updateKeybindButton(_ globalKeybindPreference : GlobalKeybindPreferences) {
    shortcutButton.title = globalKeybindPreference.description
    setHotKeyButton.title = "HotKey: \(globalKeybindPreference.description)"
  }
  
}

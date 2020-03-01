import Cocoa

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

var action: (()->())? = nil

func performAirpodsAction() {
  if action != nil {
    action!()
  }
}

class StatusMenuController: NSObject, NSMenuDelegate, BluetoothConnectorListener {
  
  let bluetooth = BluetoothConnector()
  
  @IBOutlet weak var statusMenu: NSMenu!
  
  override func awakeFromNib() {
    statusItem.menu = statusMenu
    statusMenu.delegate = self
    
    guard let button = statusItem.button else { return }
    
    let statusIcon = NSImage(named: "icon")
    statusIcon?.isTemplate = true
    button.image = statusIcon
    button.target = self
    
    let mouseView = MouseHandlerView(frame: button.frame)
    
    mouseView.onLeftMouseDown = {
      button.highlight(true)
      performAirpodsAction()
    }
    
    mouseView.onLeftMouseUp = {
      button.highlight(false)
    }
    
    mouseView.onRightMouseDown = {
      button.performClick(NSApp.currentEvent)
    }
    
    button.addSubview(mouseView)
    
    bluetooth.register(listener: self)
    
    self.setStatusItemIProps()
  }
  
  func setStatusItemIProps() {
    guard let button = statusItem.button else { return }
    
    if bluetooth.isConnected {
      button.image = NSImage(named: "icon-inverted")
      action = {
//        self.disconnect(_:)
        self.disconnect(button)
      }
      button.toolTip = bluetooth.bluetoothDevice.name
    } else {
      button.image = NSImage(named: "icon")
      action = {
//        self.connect(_:)
        self.connect(button)
      }
    }
  }
  
  func connected() {
    self.setStatusItemIProps()
  }
  
  func disconnected() {
    self.setStatusItemIProps()
  }
  
  func connect(_ sender: Any?) {
    bluetooth.connect()
  }
  
  func disconnect(_ sender: Any?) {
    bluetooth.disconnect()
  }
  
}

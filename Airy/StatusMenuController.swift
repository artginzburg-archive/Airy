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
  
  @IBOutlet weak var batteryStatusButton: NSMenuItem!
  
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
  
  func menuNeedsUpdate(_ menu: NSMenu) {
    checkBattery()
  }
  
  func checkBattery() {
    
    if bluetooth.isConnected {
      
      let commandLeft = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentLeft | tr -d \\; | awk '{print $3}'"
      let commandRight = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentRight | tr -d \\; | awk '{print $3}'"
      let commandCase = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentCase | tr -d \\; | awk '{print $3}'"
      
      var batteryString : String = ""
      
      let leftBattery = shell(commandLeft)
      if leftBattery != "0" {
        batteryString.append("L: \(leftBattery)%")
      }
      
      let rightBattery = shell(commandRight)
      if rightBattery != "0" {
        batteryString.append("  R: \(rightBattery)%")
      }
      
      let caseBattery = shell(commandCase)
      if caseBattery != "0" {
        batteryString.append("  C: \(caseBattery)%")
      }
      
      if !batteryString.isEmpty {
        batteryStatusButton.isHidden = false
        batteryStatusButton.title = batteryString
      }
      
    } else {
      
      batteryStatusButton.isHidden = true
      
    }
    
  }
  
  func setStatusItemIProps() {
    
    guard let button = statusItem.button else { return }
    
    checkBattery()
    
    if bluetooth.isConnected {
      
      button.image = NSImage(named: "icon-inverted")
      action = {
        self.disconnect(button)
      }
      button.toolTip = bluetooth.bluetoothDevice.name
      
    } else {
      
      button.image = NSImage(named: "icon")
      action = {
        self.connect(button)
      }
      button.toolTip = ""
      
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

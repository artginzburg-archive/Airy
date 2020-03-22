import Cocoa
import LoginServiceKit

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
var initialSquareLength: CGFloat = 0

var action: (()->())? = nil

func performAirpodsAction() {
  if action != nil {
    action!()
  }
}

class StatusMenuController: NSObject, NSMenuDelegate, BluetoothConnectorListener {
  
  let bluetooth = BluetoothConnector()
  
  let statusIconFilled = NSImage(named: "statusIcon-filled")
  let statusIconContour = NSImage(named: "statusIcon-contour")
  
  let statusIconRight = NSImage(named: "statusIcon-right")
  let statusIconLeft = NSImage(named: "statusIcon-left")
  
  var leftAirpodFilled: NSImage = NSImage()
  var rightAirpodFilled: NSImage = NSImage()
  var leftAirpodContour: NSImage = NSImage()
  var rightAirpodContour: NSImage = NSImage()
  
  @IBOutlet weak var statusMenu: NSMenu!
  
  private var timer: Timer?
  
  @IBOutlet weak var nameButton: NSMenuItem!
  @IBOutlet weak var connectOrDisconnectButton: NSMenuItem!
  
  @IBOutlet weak var smallBatteryButton: NSMenuItem!
  @IBOutlet weak var secondaryBatteryButton: NSMenuItem!
  @IBOutlet weak var batteryStatusButton: NSMenuItem!
  @IBOutlet weak var caseBatteryStatusButton: NSMenuItem!
  
  @IBOutlet weak var preferencesButton: NSMenuItem!
  
  @IBOutlet weak var launchAtLoginButton: NSMenuItem!
  
  @IBAction func launchAtLoginClicked(_ sender: NSMenuItem) {
    LoginServiceKit.toggle()
  }
  
  @IBAction func connectOrDisconnectClicked(_ sender: NSMenuItem) {
    performAirpodsAction()
  }
  
  override func awakeFromNib() {
    statusItem.menu = statusMenu
    statusMenu.delegate = self
    
    self.leftAirpodFilled = (statusIconFilled?.trim(CGRect(x: 0, y: 0, width: ((statusIconFilled?.size.width)! / 2), height: (statusIconFilled?.size.height)!)))!
    self.rightAirpodFilled = (statusIconFilled?.trim(CGRect(x: ((statusIconFilled?.size.width)! / 2), y: 0, width: (statusIconFilled?.size.width)!, height: (statusIconFilled?.size.height)!)))!
    
    self.leftAirpodContour = (statusIconContour?.trim(CGRect(x: 0, y: 0, width: ((statusIconContour?.size.width)! / 2), height: (statusIconContour?.size.height)!)))!
    self.rightAirpodContour = (statusIconContour?.trim(CGRect(x: ((statusIconContour?.size.width)! / 2), y: 0, width: (statusIconContour?.size.width)!, height: (statusIconContour?.size.height)!)))!
    
    
    if Constants.isFirstLaunch || NSApp.isOptionKeyDown {
      preferencesButton.expandSubmenu()
    }
    
    guard let button = statusItem.button else { return }
    
    button.alphaValue = 0
    
    let statusIcon = statusIconContour
    statusIcon?.isTemplate = true
    button.image = statusIcon
    
    button.fade(checkInEar() ? 1 : 0.6, 0.6)
    
    initialSquareLength = (button.image?.size.width ?? 18) + (button.image?.size.width ?? 18) / 1.5
    
    button.target = self
    
    let mouseView = MouseHandlerView(frame: button.frame)
    
    mouseView.onLeftMouseDown = {
      button.highlight(true)
      if self.statusItemShouldShowMenu() {
        button.performClick(NSApp.currentEvent)
      } else {
        performAirpodsAction()
      }
    }
    
    mouseView.onLeftMouseUp = {
      button.highlight(false)
    }
    
    button.addSubview(mouseView)
    
    button.setButtonType(.accelerator)
    
    bluetooth.register(listener: self)
    
    setStatusItemIProps()
    
    timer = nil
    updateTimer()
    initTimer()
  }
  
  private func statusItemShouldShowMenu() -> Bool {
    !NSApp.isLeftMouseDown || NSApp.isOptionKeyDown
  }
  
  func menuNeedsUpdate(_ menu: NSMenu) {
    checkBattery()
    
    let quote = bluetooth.bluetoothDevice.name ?? "AirPods"
    let font = NSFont.systemFont(ofSize: 12)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font
    ]
    let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
    nameButton.attributedTitle = attributedQuote
    
    let connected = bluetooth.isConnected
    
    connectOrDisconnectButton.title = connected ? "Disconnect" : "Connect to AirPods"
    connectOrDisconnectButton.indentationLevel = connected ? nameButton.indentationLevel + 1 : nameButton.indentationLevel
    nameButton.isHidden = !connected
    smallBatteryButton.isHidden = !connected
    statusMenu.item(at: statusMenu.index(of: smallBatteryButton) - 1)?.isHidden = !connected
    secondaryBatteryButton.isHidden = connected
    
    launchAtLoginButton.state.by(LoginServiceKit.isExistLoginItems())
  }
  
  func updateTimer() {
    checkBattery()
    _ = checkInEar()
  }
  
  func initTimer() {
    self.timer = Timer.new(every: 1.second) {
      self.updateTimer()
    }
    self.timer!.start()
  }
  
  func differenceBetweenNumbers(a: Int, b: Int) -> (Int) {
    return a - b
  }
  
  func mathOperation(someFunc: (Int, Int) -> Int, a: Int, b: Int) -> (Int) {
    return  someFunc(a, b)
  }
  
  func checkInEar() -> Bool {
    
    var returnValue: Bool = false
    
    let minimumAlphaValue: CGFloat = 0.6
    let maximumAlphaValue: CGFloat = 1
    let animationDuration: TimeInterval = 1
    
    let inEar = bluetooth.bluetoothDevice.getProperty("InEar").components(separatedBy: .whitespacesAndNewlines)[0].toInteger()
    
    if let button = statusItem.button {
      
      if bluetooth.isConnected {
        if inEar == 1 {
          returnValue = true
          
          if button.alphaValue == minimumAlphaValue {
            button.fade(maximumAlphaValue, animationDuration)
          }
        } else {
          if button.alphaValue == maximumAlphaValue {
            button.fade(minimumAlphaValue, animationDuration)
          }
        }
      } else {
        if button.alphaValue == minimumAlphaValue {
          button.fade(maximumAlphaValue, animationDuration)
        }
      }
      
    }
    return returnValue
  }
  
  func checkBattery() {
    
    if bluetooth.isConnected {
      
      var batteryString : String = ""
      var leftBatteryIsEmpty : Bool = true
      var rightBatteryIsEmpty : Bool = true
      
      let leftBattery = bluetooth.bluetoothDevice.getProperty("BatteryPercentLeft").toInteger()
      if leftBattery != 0 {
        leftBatteryIsEmpty = false
        batteryString.append("L: \(leftBattery) %")
      }
      
      let rightBattery = bluetooth.bluetoothDevice.getProperty("BatteryPercentRight").toInteger()
      if rightBattery != 0 {
        rightBatteryIsEmpty = false
        batteryString.append("  R: \(rightBattery) %")
      }
      
      if leftBatteryIsEmpty && !rightBatteryIsEmpty {
        if let button = statusItem.button {
          button.transition(statusIconRight)
        }
      }
      if !leftBatteryIsEmpty && rightBatteryIsEmpty {
        if let button = statusItem.button {
          button.transition(statusIconLeft)
        }
      }
      
      if !leftBatteryIsEmpty && !rightBatteryIsEmpty {
        if let button = statusItem.button {
          button.transition(statusIconFilled)
        }
        
        let difference: Int = abs(mathOperation(someFunc: differenceBetweenNumbers, a: leftBattery, b: rightBattery))
        
        if difference < 5 {
          let minimalBattery = min(leftBattery, rightBattery)
          batteryString = "\(minimalBattery) %"
        }
      }
      
      caseBatteryStatusButton.isHidden = true
      let caseBattery = bluetooth.bluetoothDevice.getProperty("BatteryPercentCase").toInteger()
      if caseBattery != 0 {
        caseBatteryStatusButton.title = "Case: \(caseBattery) %"
        caseBatteryStatusButton.isHidden = false
      }
      
      if !batteryString.isEmpty {
        batteryStatusButton.isHidden = false
        batteryStatusButton.title = batteryString
      }
      
    } else {
      
      batteryStatusButton.isHidden = true
      caseBatteryStatusButton.isHidden = true
      
    }
    
  }
  
  func setStatusItemIProps() {
    
    guard let button = statusItem.button else { return }
    
    if bluetooth.isConnected {
      
      button.transition(statusIconFilled)
      action = {
        self.disconnect(button)
      }
      button.toolTip = bluetooth.bluetoothDevice.name
      
    } else {
      
      button.transition(statusIconContour)
      action = {
        self.connect(button)
      }
      button.toolTip = ""
      
    }
    
    checkBattery()
    
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
  
  @IBAction func animateQuit(_ sender: Any?) {
    NSApp.terminateAnimated(sender)
  }
  
}

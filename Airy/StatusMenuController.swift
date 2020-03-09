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
  @IBOutlet weak var smallPreferencesButton: NSMenuItem!
  
  @IBOutlet weak var launchAtLoginButton: NSMenuItem!
  
  @IBAction func launchAtLoginClicked(_ sender: NSMenuItem) {
    if LoginServiceKit.isExistLoginItems() {
      LoginServiceKit.removeLoginItems()
    } else {
      LoginServiceKit.addLoginItems()
    }
  }
  
  @IBAction func connectOrDisconnectClicked(_ sender: NSMenuItem) {
    performAirpodsAction()
  }
  
  @IBAction func animateQuit(_ sender: Any?) {
    statusItem.button?.fade(0, 0.25)
    
    statusItem.length = initialSquareLength
    
    let quitTimer = Timer.new(every: 10.millisecond) {
      statusItem.length -= statusItem.length / initialSquareLength * 2.5
      if statusItem.length <= 1 {
        NSApp.terminate(sender)
      }
    }
    quitTimer.start()
  }
  
  override func awakeFromNib() {
    statusItem.menu = statusMenu
    statusMenu.delegate = self
    
    self.leftAirpodFilled = (statusIconFilled?.trim(CGRect(x: 0, y: 0, width: ((statusIconFilled?.size.width)! / 2), height: (statusIconFilled?.size.height)!)))!
    self.rightAirpodFilled = (statusIconFilled?.trim(CGRect(x: ((statusIconFilled?.size.width)! / 2), y: 0, width: (statusIconFilled?.size.width)!, height: (statusIconFilled?.size.height)!)))!
    
    self.leftAirpodContour = (statusIconContour?.trim(CGRect(x: 0, y: 0, width: ((statusIconContour?.size.width)! / 2), height: (statusIconContour?.size.height)!)))!
    self.rightAirpodContour = (statusIconContour?.trim(CGRect(x: ((statusIconContour?.size.width)! / 2), y: 0, width: (statusIconContour?.size.width)!, height: (statusIconContour?.size.height)!)))!
    
    
    if UserDefaults.isFirstLaunch {
      expandPreferences()
    }
    
    guard let button = statusItem.button else { return }
    
    button.alphaValue = 0
    
    let statusIcon = statusIconContour
    statusIcon?.isTemplate = true
    button.image = statusIcon
    
    button.fade(checkInEar() ? 1 : 0.5, 0.6)
    
    initialSquareLength = (button.image?.size.width ?? 18) + (button.image?.size.width ?? 18) / 1.5
    
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
    
    setStatusItemIProps()
    
    timer = nil
    updateTimer()
    initTimer()
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
    
//    batteryStatusButton.image = leftAirpodFilled
    
    let connected = bluetooth.isConnected
    
    connectOrDisconnectButton.title = connected ? "Disconnect" : "Connect to AirPods"
    connectOrDisconnectButton.indentationLevel = connected ? 2 : 1
    nameButton.isHidden = connected ? false : true
    smallBatteryButton.isHidden = connected ? false : true
    statusMenu.item(at: statusMenu.index(of: smallBatteryButton) - 1)?.isHidden = connected ? false : true
    secondaryBatteryButton.isHidden = connected ? true : false
    
    launchAtLoginButton.state.by(LoginServiceKit.isExistLoginItems())
  }
  
  func expandPreferences() {
    if preferencesButton.hasSubmenu {
      let sub = preferencesButton.submenu
      guard let subItems = sub?.items else { return }
      
      let preferencesButtonPosition = statusMenu.index(of: preferencesButton)
      preferencesButton.isHidden = true
      
      statusMenu.showsStateColumn = true
      for item in statusMenu.items {
        item.indentationLevel = 0
      }
      for item in subItems {
        if !item.isSeparatorItem {
          print(item)
          sub?.removeItem(item)
          item.indentationLevel = 1
          statusMenu.insertItem(item, at: preferencesButtonPosition + 1)
        }
      }
      
      statusMenu.removeItem(preferencesButton)
      
      smallPreferencesButton?.isHidden = false
      statusMenu.removeItem(smallPreferencesButton!)
      statusMenu.insertItem(smallPreferencesButton!, at: preferencesButtonPosition)
    }
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
  
  func getAirPodsProperty(_ property: String) -> String {
    let command = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep \(property) | tr -d \\; | awk '{print $3}'"
    return shell(command).condenseWhitespace()
  }
  
  func checkInEar() -> Bool {
    
    var returnValue: Bool = false
    
    let minimumAlphaValue: CGFloat = 0.5
    let maximumAlphaValue: CGFloat = 1
    let animationDuration: TimeInterval = 1
    
    let inEar = getAirPodsProperty("InEar").components(separatedBy: .whitespacesAndNewlines)[0].toInteger()
    
    if let button = statusItem.button {
      
      if bluetooth.isConnected && inEar == 1 {
        returnValue = true
        
        if button.alphaValue == minimumAlphaValue {
          button.fade(maximumAlphaValue, animationDuration)
        }
      } else {
        if button.alphaValue == maximumAlphaValue {
          button.fade(minimumAlphaValue, animationDuration)
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
      
      let leftBattery = getAirPodsProperty("BatteryPercentLeft").toInteger()
      if leftBattery != 0 {
        leftBatteryIsEmpty = false
        batteryString.append("L: \(leftBattery)%")
      }
      
      let rightBattery = getAirPodsProperty("BatteryPercentRight").toInteger()
      if rightBattery != 0 {
        rightBatteryIsEmpty = false
        batteryString.append("  R: \(rightBattery)%")
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
          batteryString = "\(minimalBattery)%"
        }
      }
      
      caseBatteryStatusButton.isHidden = true
      let caseBattery = getAirPodsProperty("BatteryPercentCase").toInteger()
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
    
    //    NSAnimationContext.runAnimationGroup({_ in
    //      //Indicate the duration of the animation
    //      NSAnimationContext.current.duration = 5.0
    //      //What is being animated? In this example I’m making a view transparent
    //      button.animator().alphaValue = 0.0
    //    }, completionHandler:{
    //      //In here we add the code that should be triggered after the animation completes.
    //      print("Animation completed")
    //    })
    
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
  
}

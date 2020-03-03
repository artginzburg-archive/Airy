import Cocoa
import LoginServiceKit

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

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
  
  @IBOutlet weak var statusMenu: NSMenu!
  
  @IBOutlet weak var batteryStatusButton: NSMenuItem!
  
  @IBOutlet weak var launchAtLoginButton: NSMenuItem!
  @IBAction func launchAtLoginClicked(_ sender: NSMenuItem) {
    if LoginServiceKit.isExistLoginItems() {
      LoginServiceKit.removeLoginItems()
    } else {
      LoginServiceKit.addLoginItems()
    }
  }
  
  @IBAction func animateQuit(_ sender: Any?) {
    NSAnimationContext.runAnimationGroup({_ in
      NSAnimationContext.current.duration = 0.2
      statusItem.button?.animator().alphaValue = 0
    }, completionHandler:{
//      print("Quit animation completed")
      NSApp.terminate(sender)
    })
  }
  
  @IBOutlet weak var preferencesButton: NSMenuItem!
  @IBOutlet weak var smallPreferencesButton: NSMenuItem!
  
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
  
  private var timer:Timer?
  
  func updateTimer() {
    checkBattery()
  }
  
  func initTimer() {
    self.timer = Timer.new(every: 5.second) {
      self.updateTimer()
    }
    self.timer!.start()
  }
  
  override func awakeFromNib() {
    statusItem.menu = statusMenu
    statusMenu.delegate = self
    
    if UserDefaults.isFirstLaunch() {
      expandPreferences()
    }
    
    guard let button = statusItem.button else { return }
    
    button.alphaValue = 0
    let statusIcon = statusIconContour
    statusIcon?.isTemplate = true
    button.image = statusIcon
    button.target = self
    
    NSAnimationContext.runAnimationGroup({_ in
      NSAnimationContext.current.duration = 0.3
      statusItem.button?.animator().alphaValue = 1
    }, completionHandler:{
//      print("Start animation completed")
    })
    
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
    
    timer = nil
    updateTimer()
    initTimer()
  }
  
  func menuNeedsUpdate(_ menu: NSMenu) {
    checkBattery()
    
    launchAtLoginButton.state.by(LoginServiceKit.isExistLoginItems())
  }
  
  func checkBattery() {
    
    if bluetooth.isConnected {
      
      let commandLeft = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentLeft | tr -d \\; | awk '{print $3}'"
      let commandRight = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentRight | tr -d \\; | awk '{print $3}'"
      let commandCase = "defaults read /Library/Preferences/com.apple.Bluetooth    | grep BatteryPercentCase | tr -d \\; | awk '{print $3}'"
      
      var batteryString : String = ""
      var leftBatteryIsEmpty : Bool = true
      var rightBatteryIsEmpty : Bool = true
      
      let leftBattery = shell(commandLeft).condenseWhitespace()
      if leftBattery != "0" {
        leftBatteryIsEmpty = false
        batteryString.append("L: \(leftBattery)%")
      }
      
      let rightBattery = shell(commandRight).condenseWhitespace()
      if rightBattery != "0" {
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
      
      func differenceBetweenNumbers(a: Int, b:Int) -> (Int) {
        return a - b
      }
      
      func mathOperation(someFunc: (Int, Int) -> Int, a: Int, b: Int) -> (Int) {
        return  someFunc(a, b)
      }
      
      if !leftBatteryIsEmpty && !rightBatteryIsEmpty {
        if let button = statusItem.button {
          button.transition(statusIconFilled)
        }
        
        let difference = mathOperation(someFunc: differenceBetweenNumbers, a: Int(leftBattery)!, b: Int(rightBattery)!)
        
        if difference < 5 {
          let miminalBattery = min(leftBattery, rightBattery)
          batteryString = "\(miminalBattery)%"
        }
      }
      
      let caseBattery = shell(commandCase).condenseWhitespace()
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
    
//    let leftAirpodFilled = statusIconFilled?.trim(CGRect(x: 0, y: 0, width: ((statusIconFilled?.size.width)! / 2), height: (statusIconFilled?.size.height)!))
//    let rightAirpodFilled = statusIconFilled?.trim(CGRect(x: ((statusIconFilled?.size.width)! / 2), y: 0, width: (statusIconFilled?.size.width)!, height: (statusIconFilled?.size.height)!))
//
//    let leftAirpodContour = statusIconContour?.trim(CGRect(x: 0, y: 0, width: ((statusIconContour?.size.width)! / 2), height: (statusIconContour?.size.height)!))
//    let rightAirpodContour = statusIconContour?.trim(CGRect(x: ((statusIconContour?.size.width)! / 2), y: 0, width: (statusIconContour?.size.width)!, height: (statusIconContour?.size.height)!))
    
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

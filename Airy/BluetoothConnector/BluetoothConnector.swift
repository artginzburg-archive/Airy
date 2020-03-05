import IOBluetooth

class BluetoothConnector {
  
  private var listeners: [BluetoothConnectorListener] = []
  
  public var bluetoothDevice: IOBluetoothDevice
  
  public var isConnected: Bool {
    get {
      self.bluetoothDevice.isConnected()
    }
  }
  
  init() {
    if let device = IOBluetoothDevice(addressString: BluetoothConnector.findAirPods()) {
      self.bluetoothDevice = device
      
      if !device.isPaired() {
        print("Please pair to your AirPods first.")
        exit(1)
      }
      
      device.register(forDisconnectNotification: self, selector: #selector(self.on(disconnect:)))
      IOBluetoothDevice.register(forConnectNotifications: self, selector: #selector(self.on(connect:)))
    } else {
      print("Could not find any AirPods")
      exit(1)
    }
  }
  
  public func register(listener: BluetoothConnectorListener) {
    self.listeners.append(listener)
  }
  
  @objc private func on(disconnect sender: Any?) {
    if !self.bluetoothDevice.isConnected() {
      self.listeners.forEach { $0.disconnected() }
    }
  }
  
  @objc private func on(connect sender: Any?) {
    if self.bluetoothDevice.isConnected() {
      self.listeners.forEach { $0.connected() }
    }
  }
  
  public func connect() {
    if !self.bluetoothDevice.isConnected() {
      self.bluetoothDevice.openConnection()
      self.listeners.forEach { $0.connected() }
    }
  }
  
  public func disconnect() {
    if self.bluetoothDevice.isConnected() {
      self.bluetoothDevice.closeConnection()
      self.listeners.forEach { $0.disconnected() }
    }
  }
  
  private static func findAirPods() -> String? {
    var address: String? = nil
    
    IOBluetoothDevice.pairedDevices().forEach({(device) in
      guard let device = device as? IOBluetoothDevice,
        let addressString = device.addressString,
        let deviceName = device.name
        else { return }
      
      if deviceName.hasSuffix("AirPods") && device.isHandsFreeDevice {
        address = addressString
        return
      }
    })
    
    return address
  }
  
}

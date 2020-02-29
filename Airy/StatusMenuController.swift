//
//  StatusMenuController.swift
//  Airy
//
//  Created by Arthur Ginzburg on 29.02.2020.
//  Copyright © 2020 Art Ginzburg. All rights reserved.
//

import Cocoa

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

class StatusMenuController: NSObject, NSMenuDelegate, BluetoothConnectorListener {
  
  let bluetooth = BluetoothConnector()
  
  @IBOutlet weak var statusMenu: NSMenu!
  
  override func awakeFromNib() {
//    statusItem.menu = statusMenu
    statusMenu.delegate = self
    
    guard let button = statusItem.button else { return }
    
    let statusIcon = NSImage(named: "icon")
    statusIcon?.isTemplate = true
    button.image = statusIcon
    button.target = self
    
    bluetooth.register(listener: self)
    
    self.setStatusItemIProps()
  }
  
  func setStatusItemIProps() {
    guard let button = statusItem.button else { return }
    
    if bluetooth.isConnected {
      button.image = NSImage(named: "icon-inverted")
      button.action = #selector(disconnect(_:))
      button.toolTip = bluetooth.bluetoothDevice.name
    } else {
      button.image = NSImage(named: "icon")
      button.action = #selector(connect(_:))
    }
  }
  
  func connected() {
    self.setStatusItemIProps()
  }
  
  func disconnected() {
    self.setStatusItemIProps()
  }
  
  @objc func connect(_ sender: Any?) {
    bluetooth.connect()
  }
  
  @objc func disconnect(_ sender: Any?) {
    bluetooth.disconnect()
  }
  
}

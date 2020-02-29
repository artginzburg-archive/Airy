//
//  AppDelegate.swift
//  Airy
//
//  Created by Arthur Ginzburg on 29.02.2020.
//  Copyright © 2020 Art Ginzburg. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldHandleReopen(_ sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool
  {
    if let button = statusItem.button {
      button.performClick(nil)
      button.momentaryHighlight()
    }
    return true
  }
}

//
//  mouseHandlerView.swift
//  Airy
//
//  Created by Arthur Ginzburg on 01.03.2020.
//  Copyright © 2020 Art Ginzburg. All rights reserved.
//

import Cocoa

class MouseHandlerView: NSView {
  
  var onLeftMouseDown: (()->())? = nil
  
  override func mouseDown(with event: NSEvent) {
    onLeftMouseDown == nil ? super.mouseDown(with: event) : onLeftMouseDown!()
  }
  
  var onRightMouseDown: (()->())? = nil
  
  override func rightMouseDown(with event: NSEvent) {
    onRightMouseDown == nil ? super.rightMouseDown(with: event) : onRightMouseDown!()
  }
  
  var onOtherMouseDown: (()->())? = nil
  
  override func otherMouseDown(with event: NSEvent) {
    onOtherMouseDown == nil ? super.otherMouseDown(with: event) : onOtherMouseDown!()
  }
  
}

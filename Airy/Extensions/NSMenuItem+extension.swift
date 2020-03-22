import Cocoa

extension NSMenuItem
{
  func expandSubmenu()
  {
    guard let parentMenu = menu else { return }
    if hasSubmenu {
      guard let sub = submenu else { return }
      let subItems = sub.items
      
      let buttonPosition = parentMenu.index(of: self)
      isHidden = true
      
      if sub.showsStateColumn {
        parentMenu.showsStateColumn = true
        
        for item in parentMenu.items {
          if item.indentationLevel > 0 {
            item.indentationLevel = item.indentationLevel - 1
          } else {
            item.indentationLevel = 0
          }
        }
      }
      
      for item in subItems {
        if !item.isSeparatorItem {
          sub.removeItem(item)
          item.indentationLevel = item.indentationLevel + 1
          parentMenu.insertItem(item, at: buttonPosition + 1)
        }
      }
      
      let smallButton = NSMenuItem()
      smallButton.isEnabled = false
      
      let quote = title
      let font = NSFont.systemFont(ofSize: 12)
      let attributes: [NSAttributedString.Key: Any] = [
        .font: font
      ]
      let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
      smallButton.attributedTitle = attributedQuote
      
      parentMenu.insertItem(smallButton, at: buttonPosition)
      parentMenu.removeItem(self)
    }
  }
}

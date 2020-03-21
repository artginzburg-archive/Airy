import LoginServiceKit

public extension LoginServiceKit {
  
  static func toggle() {
    if LoginServiceKit.isExistLoginItems() {
      LoginServiceKit.removeLoginItems()
    } else {
      LoginServiceKit.addLoginItems()
    }
  }
  
}

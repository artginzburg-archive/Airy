import Foundation

extension NSAttributedString {
  
  var stringMutable: String {
    get {
      string
    }
    set {
      setValue(newValue, forKey: "string")
    }
  }
  
}

import Cocoa

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
var initialSquareLength: CGFloat = 0

var action: (()->())? = nil

func performAirpodsAction() {
  if action != nil {
    action!()
  }
}

func differenceBetweenNumbers(a: Int, b: Int) -> (Int) {
  a - b
}

func mathOperation(someFunc: (Int, Int) -> Int, a: Int, b: Int) -> (Int) {
  someFunc(a, b)
}

import Foundation

extension UserDefaults {

  static func isFirstLaunch() -> Bool {
    let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBefore")

    if isFirstLaunch {
      UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBefore")
      UserDefaults.standard.synchronize()
    }
    return isFirstLaunch
  }
  
}

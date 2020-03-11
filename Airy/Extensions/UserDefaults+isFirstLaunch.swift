import Foundation

extension UserDefaults {

  static var isFirstLaunch: Bool {
    let hasBeenLaunchedBefore = "hasBeenLaunchedBefore"
    let isFirstLaunch = !standard.bool(forKey: hasBeenLaunchedBefore)

    if isFirstLaunch {
      standard.set(true, forKey: hasBeenLaunchedBefore)
      standard.synchronize()
    }
    return isFirstLaunch
  }
  
}

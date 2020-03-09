import Cocoa

extension NSStatusBarButton
{
  func momentaryHighlight(_ duration: Double = 0.2)
  {
    self.highlight(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      self.highlight(false)
    }
  }
  
  func transition(_ to: NSImage!, _ duration: Double = 0.25)
  {
    guard let currentImage = self.image, currentImage != to else { return }
    let animation = CATransition()
    animation.duration = duration
    animation.type = CATransitionType.fade
    layer?.add(animation, forKey: "ImageFade")
    self.image = to
  }
  
  func fade(_ to: CGFloat, _ duration: TimeInterval = 1)
  {
    NSAnimationContext.runAnimationGroup({_ in
      NSAnimationContext.current.duration = duration
      self.animator().alphaValue = to
    })
  }
}

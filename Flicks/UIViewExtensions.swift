import Foundation
import UIKit

extension UIView {
  func fadeIn() {
    self.alpha = 0
    self.hidden = false
    UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
      self.alpha = 1.0
      }, completion: nil)
  }

//  func fadeOut() {
//    UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//      self.alpha = 0.0
//      }, completion: { _ in self.hidden = true })
//  }
}
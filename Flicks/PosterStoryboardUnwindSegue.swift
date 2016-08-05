//
//  PosterStoryboardUnwindSegue.swift
//  Flicks
//
//  Created by Gil Birman on 8/5/16.
//  Copyright © 2016 Gil Birman. All rights reserved.
//

import UIKit

class PosterStoryboardUnwindSegue: UIStoryboardSegue {
  override func perform() {
    // Assign the source and destination views to local variables.
    let secondVCView = self.sourceViewController.view as UIView!
    let firstVCView = self.destinationViewController.view as UIView!

    let window = UIApplication.sharedApplication().keyWindow
    window?.insertSubview(firstVCView, aboveSubview: secondVCView)

    let scale = CGAffineTransformMakeScale(1.3, 1.3)

    firstVCView.transform = scale
    firstVCView.alpha = 0
    secondVCView.transform = CGAffineTransformIdentity

    UIView.animateWithDuration(0.4, animations: { () -> Void in
      firstVCView.transform = CGAffineTransformIdentity
      secondVCView.transform = scale
      firstVCView.alpha = 1

    }) { (Finished) -> Void in
      self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
    }
  }
}

//
//  PosterStoryboardSegue.swift
//  Flicks
//
//  Created by Gil Birman on 8/4/16.
//  Copyright © 2016 Gil Birman. All rights reserved.
//

import UIKit

class PosterStoryboardSegue: UIStoryboardSegue {

  override func perform() {
    // Assign the source and destination views to local variables.
    let firstVCView = self.sourceViewController.view as UIView!
    let secondVCView = self.destinationViewController.view as UIView!
    let scale = CGAffineTransformMakeScale(1.3, 1.3)

    firstVCView.transform = CGAffineTransformIdentity
    secondVCView.transform = scale
    secondVCView.alpha = 0

    // Access the app's key window and insert the destination view above the current (source) one.
    let window = UIApplication.sharedApplication().keyWindow
    window?.insertSubview(secondVCView, aboveSubview: firstVCView)

    // Animate the transition.
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      firstVCView.transform = scale
      secondVCView.transform = CGAffineTransformIdentity
      secondVCView.alpha = 1.0

    }) { (Finished) -> Void in
      firstVCView.transform = CGAffineTransformIdentity
      self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                                                      animated: false,
                                                      completion: nil)
    }
  }
}

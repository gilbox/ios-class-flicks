//
//  PosterViewController.swift
//  Flicks
//
//  Created by Gil Birman on 8/4/16.
//  Copyright © 2016 Gil Birman. All rights reserved.
//

import UIKit

class PosterViewController: UIViewController, UIScrollViewDelegate {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var posterView: UIImageView!
  var posterImage: UIImage?

  override func viewDidLoad() {
    super.viewDidLoad()

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PosterViewController.tappedPosterImage))
    posterView.addGestureRecognizer(tapGesture)
    posterView.userInteractionEnabled = true
    posterView.image = posterImage

    scrollView.delegate = self
    scrollView.minimumZoomScale = 1
    scrollView.maximumZoomScale = 2

    scrollView.contentSize = posterView.image!.size
    scrollView.zoomScale = 0.5
  }

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return posterView
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tappedPosterImage() {
    performSegueWithIdentifier("unwindToDetailViewController", sender: self)
  }
}

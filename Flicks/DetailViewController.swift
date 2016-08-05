//
//  DetailViewController.swift
//  Flicks
//
//  Created by Gil Birman on 8/1/16.
//  Copyright © 2016 Gil Birman. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class DetailViewController: UIViewController {

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var playTrailerButton: UIButton!

  let baseUrl = "http://image.tmdb.org/t/p/w1000"
  var lowResImage: UIImage?
  var movie: NSDictionary!
  var videoInfo: NSDictionary!

  override func viewDidLoad() {
    super.viewDidLoad()

    let title = movie["title"] as! String
    let overview = movie["overview"] as! String

    titleLabel.text = title
    overviewLabel.text = overview
    overviewLabel.sizeToFit()
    infoView.frame.size.height = overviewLabel.frame.size.height + overviewLabel.frame.origin.y + 10

    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 60 + infoView.frame.origin.y + infoView.frame.size.height)

    if let lowResImage = lowResImage {
      posterImageView.image = lowResImage
    }

    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      posterImageView.setImageWithURL(imageUrl!)
    }

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tappedPosterImage))
    scrollView.addGestureRecognizer(tapGesture)

    // hide until we load the video info
    playTrailerButton.hidden = true
    getVideoData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tappedPosterImage() {
    performSegueWithIdentifier("PosterViewSegue", sender: self)
  }

  func getVideoData() {
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let movieId = movie["id"]!
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey)")

    let request = NSURLRequest(
      URL: url!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)

    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue: NSOperationQueue.mainQueue()
    )

    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {
      (dataOrNil, response, error) in
      if let data = dataOrNil {
        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
          data, options:[]) as? NSDictionary {

          if let results = responseDictionary["results"] as? [NSDictionary] where results.count > 0 {
            self.videoInfo = results[0]
            if let site = self.videoInfo["site"] as? String where site == "YouTube" {
              self.playTrailerButton.fadeIn()
            }
          }
        }
      }
    })
    task.resume()
  }

  @IBAction func unwindToDetailViewController(segue: UIStoryboardSegue) {}

  @IBAction func playTrailerButtonTouchUpInside(sender: UIButton) {
    if let videoId = self.videoInfo["key"] as? String {
      let videoPlayerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
      self.presentMoviePlayerViewControllerAnimated(videoPlayerController)
    }
  }

   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
    let posterViewController = segue.destinationViewController as! PosterViewController
    posterViewController.posterImage = posterImageView.image
  }

  

}

//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Gil Birman on 8/1/16.
//  Copyright © 2016 Gil Birman. All rights reserved.
//

import UIKit
import AFNetworking
import BFRadialWaveHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

  let baseUrl = "http://image.tmdb.org/t/p/w500"
  var movies: [NSDictionary]?
  var endpoint: String! // now_playing
  var hud: BFRadialWaveHUD!
  var refreshControl: UIRefreshControl!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var layoutSegmentedControl: UISegmentedControl!
  @IBOutlet weak var gridView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()

    hud = BFRadialWaveHUD(view: self.view, fullScreen: true, circles: BFRadialWaveHUD_DefaultNumberOfCircles, circleColor: nil, mode: BFRadialWaveHUDMode.KuneKune, strokeWidth: BFRadialWaveHUD_DefaultCircleStrokeWidth)

    tableView.dataSource = self
    gridView.dataSource = self
    tableView.delegate = self
    gridView.delegate = self

    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)

    tableView.hidden = false
    gridView.hidden = true

    getData(nil)


    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func layoutSegmentedControlValueChanged(sender: UISegmentedControl) {
    print("changed! \(sender.selectedSegmentIndex)")
    tableView.hidden = sender.selectedSegmentIndex == 1
    gridView.hidden = sender.selectedSegmentIndex == 0

    if (sender.selectedSegmentIndex == 0) {
      tableView.insertSubview(refreshControl, atIndex: 0)
      tableView.reloadData()
    } else {
      gridView.insertSubview(refreshControl, atIndex: 0)
      gridView.reloadData()
    }
  }

  func refreshControlAction(refreshControl: UIRefreshControl) {
    getData(refreshControl)
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movies?.count ?? 0
  }

  func setImageForGridCell(imageUrl: NSURL, cell: GridMovieCell) {
    let imageRequest = NSURLRequest(URL: imageUrl)

    cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: {
      (imageRequest, imageResponse, image) -> Void in
      // imageResponse will be nil if the image is cached
      if imageResponse != nil {
        cell.posterView.alpha = 0.0
        cell.posterView.image = image
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          cell.posterView.alpha = 1.0
        })
      } else {
        cell.posterView.image = image
      }
      }, failure: { (imageRequest, imageResponse, error) -> Void in print("failure") })
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = gridView.dequeueReusableCellWithReuseIdentifier("GridMovieCell", forIndexPath: indexPath) as! GridMovieCell
    let movie = movies![indexPath.row]


    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      setImageForGridCell(imageUrl!, cell: cell)
    }

    return cell
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies?.count ?? 0
  }


  func setImageForTableCell(imageUrl: NSURL, cell: MovieCell) {
    let imageRequest = NSURLRequest(URL: imageUrl)

    cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: {
      (imageRequest, imageResponse, image) -> Void in
      // imageResponse will be nil if the image is cached
      if imageResponse != nil {
        cell.posterView.alpha = 0.0
        cell.posterView.image = image
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          cell.posterView.alpha = 1.0
        })
      } else {
        cell.posterView.image = image
      }
      }, failure: { (imageRequest, imageResponse, error) -> Void in print("failure") })
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    let movie = movies![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String

    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      setImageForTableCell(imageUrl!, cell: cell)
    }

    cell.titleLabel.text = title
    cell.overviewLabel.text = overview

    print("row \(indexPath.row)")
    return cell
  }

  func getData(refreshControl: UIRefreshControl?) {


    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    let request = NSURLRequest(
      URL: url!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)

    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue: NSOperationQueue.mainQueue()
    )

    errorView.hidden = true
    hud?.show()

    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {
      (dataOrNil, response, error) in
      if (error != nil) {
        print("error \(error)")
        self.errorView.hidden = false
        refreshControl?.endRefreshing()
      }
      else if let data = dataOrNil {
        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
          data, options:[]) as? NSDictionary {
          print("response: \(responseDictionary)")

          self.movies = responseDictionary["results"] as? [NSDictionary]

          if (self.layoutSegmentedControl.selectedSegmentIndex == 0) {
            self.tableView.reloadData()
          } else {
            print("grid reload data")
            self.gridView.reloadData()
          }

          refreshControl?.endRefreshing()
          self.gridView.contentInset = self.tableView.contentInset
        } // TODO: else error?
      } else {
        // TODO: is this an error?
        refreshControl?.endRefreshing()
        self.errorView.hidden = false
      }
      self.hud?.dismiss()
    })
    task.resume()
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    print("prepare segue")
    if (sender is UITableViewCell) {
      let cell = sender as! UITableViewCell
      let indexPath = tableView.indexPathForCell(cell)
      let movie = movies![indexPath!.row]

      let detailViewController = segue.destinationViewController as! DetailViewController
      detailViewController.movie = movie
    } else {

      let cell = sender as! UICollectionViewCell
      let indexPath = gridView.indexPathForCell(cell)
      let movie = movies![indexPath!.row]

      let detailViewController = segue.destinationViewController as! DetailViewController
      detailViewController.movie = movie
    }
  }

}

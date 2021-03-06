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

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UITextFieldDelegate {

  let baseUrl = "http://image.tmdb.org/t/p/w500"
  var movies: [NSDictionary]?
  var filteredMovies: [NSDictionary]?
  var endpoint: String! // now_playing
  var hud: BFRadialWaveHUD!
  var refreshControl: UIRefreshControl!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var layoutSegmentedControl: UISegmentedControl!
  @IBOutlet weak var gridView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let navigationBar = navigationController?.navigationBar {
      navigationBar.setBackgroundImage(UIImage(named: "metal"), forBarMetrics: .Default)
      navigationBar.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)

      let shadow = NSShadow()
      shadow.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
      shadow.shadowOffset = CGSizeMake(1, 1);
      shadow.shadowBlurRadius = 4;
      navigationBar.titleTextAttributes = [
        NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
        NSForegroundColorAttributeName : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9),
        NSShadowAttributeName : shadow
      ]
    }

    hud = BFRadialWaveHUD(view: self.view, fullScreen: true, circles: BFRadialWaveHUD_DefaultNumberOfCircles, circleColor: nil, mode: BFRadialWaveHUDMode.KuneKune, strokeWidth: BFRadialWaveHUD_DefaultCircleStrokeWidth)

    tableView.dataSource = self
    gridView.dataSource = self
    tableView.delegate = self
    gridView.delegate = self
    searchBar.delegate = self

    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)

    tableView.hidden = false
    gridView.hidden = true

    getData(nil)
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
  }

  func dismissKeyboard() {
    view.endEditing(true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.contentInset.top = 0
  }

  @IBAction func layoutSegmentedControlValueChanged(sender: UISegmentedControl) {
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

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText == "") {
      filteredMovies = movies

      // TODO: janky
      searchBar.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0.1)
    } else {
      filteredMovies = movies?.filter({ (movie: NSDictionary) in
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        return title.localizedCaseInsensitiveContainsString(searchText) || overview.localizedCaseInsensitiveContainsString(searchText)
      })
    }

    if (layoutSegmentedControl.selectedSegmentIndex == 0) {
      tableView.reloadData()
    } else {
      gridView.reloadData()
    }
  }

  func refreshControlAction(refreshControl: UIRefreshControl) {
    getData(refreshControl)
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredMovies?.count ?? 0
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
    let movie = filteredMovies![indexPath.row]

    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      setImageForGridCell(imageUrl!, cell: cell)
    }

    return cell
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredMovies?.count ?? 0
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
    let movie = filteredMovies![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String

    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      setImageForTableCell(imageUrl!, cell: cell)
    }

    cell.titleLabel.text = title
    cell.overviewLabel.text = overview

    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.greenColor()
    cell.selectedBackgroundView = backgroundView

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

          self.movies = responseDictionary["results"] as? [NSDictionary]
          self.filteredMovies = self.movies
//          print("movies", self.movies)

          if (self.layoutSegmentedControl.selectedSegmentIndex == 0) {
            self.tableView.reloadData()
          } else {
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
    if (sender is UITableViewCell) {
      let cell = sender as! UITableViewCell
      let indexPath = tableView.indexPathForCell(cell)
      let movie = filteredMovies![indexPath!.row]

      let detailViewController = segue.destinationViewController as! DetailViewController
      detailViewController.lowResImage = (cell as! MovieCell).posterView.image
      detailViewController.movie = movie
    } else {

      let cell = sender as! UICollectionViewCell
      let indexPath = gridView.indexPathForCell(cell)
      let movie = filteredMovies![indexPath!.row]

      let detailViewController = segue.destinationViewController as! DetailViewController
      detailViewController.lowResImage = (cell as! GridMovieCell).posterView.image
      detailViewController.movie = movie
    }
  }


}

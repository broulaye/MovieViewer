//
//  MovieViewController.swift
//  movieViewerFinal
//
//  Created by macbookair11 on 2/4/16.
//  Copyright © 2016 Broulaye. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var filteredMovies = [NSDictionary]!()
    var movies: [NSDictionary]?
    let searchController = UISearchController(searchResultsController: nil)
    var endpoint: String!
    
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.label.text = "Loading"
        spiningActivity.detailsLabel.text = "Please wait"
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
            {
               
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
                
                let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
                let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(self.endpoint)?api_key=\(apiKey)")
                let request = NSURLRequest(
                    URL: url!,
                    cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
                    timeoutInterval: 10)
                
                let session = NSURLSession(
                    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                    delegate: nil,
                    delegateQueue: NSOperationQueue.mainQueue()
                )
                
                let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                    completionHandler: { (dataOrNil, response, error) in
                        if let data = dataOrNil {
                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                data, options:[]) as? NSDictionary {
                                    print("response: \(responseDictionary)")
                                    
                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                    self.tableView.reloadData()
                                    
                            }
                        }
                })
                task.resume()
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        spiningActivity.minShowTime = 1
                        spiningActivity.hideAnimated(true)
                        
                }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies.count
        }
        
        else if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "beginning") {
        filteredMovies = movies!.filter { Movie in
            return Movie["title"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var movie = movies![indexPath.row]
        if searchController.active && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            
        let imageURL = NSURL(string: baseURL + posterPath)
        
        
        
        cell.posterView.setImageWithURL(imageURL!)
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        print("row \(indexPath.row)")
        return cell
        
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            
                    }
                    
                    
                    // Reload the tableView now that there is new data
                    self.tableView.reloadData()
                    
                    // Tell the refreshControl to stop spinning
                    refreshControl.endRefreshing()
                }})
        task.resume()
    };
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}


extension MovieViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

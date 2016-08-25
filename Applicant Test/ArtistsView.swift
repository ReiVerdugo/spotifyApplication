//
//  ArtistsView.swift
//  Applicant Test
//
//  Created by devstn5 on 2016-08-24.
//  Copyright © 2016 KogiMobile. All rights reserved.
//
// This View Controller shows the Artists View, where several artists display
// according to users' search.
// It implements CollectionView Data Source and Delegate method to show the artist found
// It also uses UISearchResultsUpdating and UISearchBarDelegate to handle user's search and
// results.
// Last, it uses DZNEmptyDataSet and SVProgressHUD libraries to provide a better UX

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet
import SVProgressHUD

// A struct that contains each artist's information
struct artistType {
    var info: JSON;
}

class ArtistsView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var searchController = UISearchController!(nil)
    var foundArtists = [JSON]() // An array of the found artist
    var selectedArtist = artistType(info: nil)
    var lastSearch = "" // We store the last search to repeat it when pull refreshing
    let refreshControl = UIRefreshControl() // Used to do pull refresh
    
    // ***************************************
    // Mark - View Controller
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar("")
        
        //Creates search controller
        self.createSearchController()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Makes the request to search for artists and populates the collectionView
    func getArtists (query : String) {
        let parameters = [
            "q" : query,
            "type" : "artist"
        ]
        SVProgressHUD.showWithStatus("Searching artists...")
        
        // Makes the request using URLRequestConvertible from Alamofire's library
        // More info in file API.swift
        Alamofire.request(Router.getArtists(parameters))
            .validate()
            .responseJSON { response in
        
            if response.result.isSuccess {
                SVProgressHUD.showSuccessWithStatus("Artists found")
                self.foundArtists = (JSON(response.result.value!))["artists"]["items"].arrayValue
            }else{
                SVProgressHUD.showErrorWithStatus("Error. Please try again")
                print(response.debugDescription)
                
            }
            self.collectionView.reloadData()
            self.collectionView.hidden = false
        }
    }
    
    // Creates the search controller to be used in the view to search by characters
    func createSearchController () {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.frame = CGRectMake(0, 0, 150, 20)
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.placeholder = "Search artists"
        self.navigationItem.titleView = self.searchController.searchBar
        
        self.searchController.searchBar.delegate = self;
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(ArtistsView.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
    }
    
    // Refresh artist when pulling the view
    func refresh(sender:AnyObject) {
        self.getArtists(lastSearch)
        refreshControl.endRefreshing()
    }
    
    // Sends information of the selected artist to the next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "artistDetail" {
            let nextController = segue.destinationViewController as! ArtistAlbums
            nextController.selectedArtist = self.selectedArtist
        }
    }
    
    // ***************************************
    // Mark - Collection View Delegate and DataSource
    //
    
    // Sets the number of items to display
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.foundArtists.count
    }
    
    // Configures the cell to display
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell",
                                                                         forIndexPath: indexPath) as! ArtistCell
        let info = self.foundArtists[indexPath.item]
        cell.artistName.text = info["name"].stringValue
        cell.artistImage.downloadImageFrom(link: info["images"][0]["url"].stringValue, contentMode: .ScaleAspectFit)
        cell.artistImage.setNeedsLayout()
        cell.artistImage.layoutIfNeeded()
        cell.artistImage.layer.cornerRadius = cell.artistImage.frame.size.height / 2;
        cell.artistImage.clipsToBounds = true
        return cell
    }
    
    // When selecting a artist, store the needed information and performs a segue to the next View Controller
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let info = self.foundArtists[indexPath.item]
        self.selectedArtist = artistType(info: info)
        self.performSegueWithIdentifier("artistDetail", sender: self)
    }
    
    // Sets the size of each item of the collection view. In this case we use the collectionView size, which adapts to device's screen size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionView.bounds.size.width/2, self.collectionView.bounds.size.width/2)
    }

    
    // ***************************************
    // Mark - Search bar functions
    //
    
    // Show collectionView when cancelButton is pressed
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.collectionView.hidden = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.lastSearch = searchController.searchBar.text!
        self.getArtists(lastSearch)
    }
    
    // When user inserts a value to search bar, performs the search if there are enough characters
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.foundArtists.removeAll(keepCapacity: false)
        
        if searchController.searchBar.text?.characters.count > 0 {
            self.collectionView.hidden = true
            

            if (searchController.searchBar.text?.characters.count)! % 3 == 0{
                self.lastSearch = searchController.searchBar.text!
                self.getArtists(lastSearch)
                
            }
            
        }
        self.collectionView.reloadData()
    }

    // ***************************************
    // MARK: - DZNEmptyDataSet
    // Set how the view display zero items. This happens when the user hasn't started searching
    // or cancels current search

    // Sets the image to show to show when there are no items
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "userIconEmpty.png");
    }
    
    // Sets the title to show to show when there are no items
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Search an artist"
    
        let attributes :Dictionary = [NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18)
        ]
        let stringWithAttributes = NSMutableAttributedString(string: text, attributes: attributes)
        return stringWithAttributes
    
    }
    
    // Sets the description (or subtitle) to show when there are no items
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    
        let text = "Use the searchbar to begin"
    
        let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.alignment = .Center
    
        let attributes :Dictionary = [NSForegroundColorAttributeName: UIColor.darkGrayColor(),
                NSFontAttributeName : UIFont.boldSystemFontOfSize(14),
                NSParagraphStyleAttributeName: paragraphStyle
        ]
        let stringWithAttributes = NSMutableAttributedString(string: text, attributes: attributes)
        return stringWithAttributes
    
    }
    
    // Sets the background color to show when there are no items
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.blackColor()
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func offsetForEmptyDataSet(scrollView: UIScrollView!) -> CGPoint {
        return CGPointMake(0, -50)
    }


}

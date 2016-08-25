//
//  ArtistAlbums.swift
//  Applicant Test
//
//  Created by devstn5 on 2016-08-24.
//  Copyright © 2016 KogiMobile. All rights reserved.
//
//  This ViewController show the previously selected artist information, as well as a list of albums
//  from that artist.
//  It implements TableView's Delegate and DataSource to configure how the albums and the info will look 
//  like

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ArtistAlbums: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedArtist = artistType(info: nil) //Previously selected artist
    @IBOutlet weak var tableView: UITableView!
    var albumList = [JSON]() // A list of the current artist's albums.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar(selectedArtist.info["name"].stringValue)
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.estimatedRowHeight = 130
        
        // Here we make the request to get artist's albums. We use artist's ID as a parameter
        Alamofire.request(Router.getAlbums(selectedArtist.info["id"].stringValue))
            .validate()
            .responseJSON { response in
                // If the result is succes populate the table, otherwise show debug description
                if response.result.isSuccess {
                    self.albumList = (JSON(response.result.value!))["items"].arrayValue
                    self.tableView.reloadData()
                } else {
                    SVProgressHUD.showErrorWithStatus("Error. Please try again")
                    print(response.debugDescription)
                    
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // ***************************************
    // MARK: - Table View Data Source and Delegate
    
    // Number of sections of the table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows to be displayed by the table
    // We use the number of albums plus one to show the artist info
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (albumList.count)
    }
    
    // Here we configure how the table view cells are gonna be displayed
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AlbumCell
            let info = albumList[indexPath.row]
            cell.albumName.text = info["name"].stringValue
            if info["images"].count != 0 {
                let link = info["images"][0]["url"].stringValue
                cell.albumImage.downloadImageFrom(link: link, contentMode: .ScaleAspectFit)
                cell.albumImage.layer.cornerRadius = cell.albumImage.frame.size.height/2
                cell.albumImage.clipsToBounds = true

            }
            let markets = info["available_markets"].arrayValue

            // If there are more than 5 albums, we take only the first five
            if markets.count > 5 {
                let markets : [JSON] = Array(markets[0...4])
                cell.markets.text = "Available in the following markets: \n"
                for market in markets {
                    cell.markets.text = cell.markets.text! + market.stringValue + "\n"
                }
                
            // If there are less than 5, but more than 1, display them without slicing the array
            } else if markets.count > 0 {
                cell.markets.text = "Available in the following markets: \n"
                for market in markets {
                    cell.markets.text = cell.markets.text! + market.stringValue + "\n"
                }

            }
            // Save external url to open on Safari
            let link = info["external_urls"]["spotify"].stringValue
            cell.externalURL = (link != "" ? link : nil)
            print(link)
            
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("artistCell") as! MainInfoCell
        cell.artistName.text = selectedArtist.info["name"].stringValue
        cell.backgroundPicture.downloadImageFrom(link: selectedArtist.info["images"][0]["url"].stringValue, contentMode: .ScaleAspectFit)
        cell.profileView.downloadImageFrom(link: selectedArtist.info["images"][0]["url"].stringValue, contentMode: .ScaleAspectFit)
        cell.numberOfFollowers.text = selectedArtist.info["followers"]["total"].stringValue + " followers"
        cell.popularity.text = "Popularity: " + selectedArtist.info["popularity"].stringValue
        return cell
    }

    // When the user taps a cell, the application should launch an external URL
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AlbumCell
            if let link = cell.externalURL {
                print(link)
                UIApplication.sharedApplication().openURL(NSURL(string: cell.externalURL!)!)
            } else {
                SVProgressHUD.showErrorWithStatus("No URL found")
            }
    }
    
    // Height for row is different depending on wether it is displaying artist's or album's info.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    
}

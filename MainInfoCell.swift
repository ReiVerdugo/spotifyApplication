//
//  MainInfoCell.swift
//  Applicant Test
//
//  Created by devstn5 on 2016-08-24.
//  Copyright © 2016 KogiMobile. All rights reserved.
//
// This class configures a custom collection view cell displaying every an artist's information
// including artist's name, profile picture, a blurred background view, the number of followers
// and popularity on Spotify

import UIKit

class MainInfoCell: UITableViewCell {
    
    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var popularity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // We give the images a round corner and a blur effect to the background's image view
        
        profileView.layer.cornerRadius = profileView.frame.size.height/2
        profileView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundPicture.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundPicture.addSubview(blurEffectView)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }


}

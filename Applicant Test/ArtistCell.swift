//
//  ArtistCell.swift
//  Applicant Test
//
//  Created by devstn5 on 2016-08-24.
//  Copyright © 2016 KogiMobile. All rights reserved.
//
// This class configures a custom collection view cell displaying every artist with photo
// and name

import UIKit

class ArtistCell: UICollectionViewCell {
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    
    // Prepares the cell to display when the user scrolls or changes view
    override func prepareForReuse() {
        super.prepareForReuse()
        self.artistImage.image = nil
        self.artistName.text = ""
    }
}

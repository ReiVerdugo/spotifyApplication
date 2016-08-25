//
//  AlbumCell.swift
//  Applicant Test
//
//  Created by devstn5 on 2016-08-24.
//  Copyright © 2016 KogiMobile. All rights reserved.
//
// This class configures a custom collection view cell displaying every artist's album with photo
// name and markets where it is available

import UIKit

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var markets: UILabel!
    var externalURL : String? = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}


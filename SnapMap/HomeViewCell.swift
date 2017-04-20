//
//  HomeViewCell.swift
//  SnapMap
//
//  Created by Lum Situ on 4/12/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit

class HomeViewCell: UITableViewCell {

    @IBOutlet weak var profileimg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    /*didSet {
        //cornerRadius
        profileimg.layoutIfNeeded()
        profileimg.layer.cornerRadius = 3
        profileimg.clipsToBounds = true
    }*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // test : cornerRadius
        profileimg.layoutIfNeeded()
        profileimg.layer.cornerRadius = 25
        profileimg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

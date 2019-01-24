//
//  StudentTableViewCell.swift
//  On The Map
///Users/ryanberry/Documents/On-The-Map/On The Map/Model
//  Created by Ryan Berry on 12/23/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {

 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

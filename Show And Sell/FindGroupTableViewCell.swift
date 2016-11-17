//
//  FindGroupTableViewCell.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/25/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class FindGroupTableViewCell: UITableViewCell {
    
    // UI Elements
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var checkBox: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

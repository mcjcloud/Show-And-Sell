//
//  ItemTableViewCell.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/15/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    // GUI components
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemCondition: UILabel!
    @IBOutlet var itemPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

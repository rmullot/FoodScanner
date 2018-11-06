//
//  NutrientTableViewCell.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

class NutrientTableViewCell: UITableViewCell {
    
    static let cellID = "NutrientTableViewCellID"
    static let heightRow: CGFloat = 44.0
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

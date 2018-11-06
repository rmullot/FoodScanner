//
//  FoodCollectionReusableView.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

class FoodCollectionReusableView: UICollectionReusableView {
    
    static let cellID = "FoodCollectionReusableViewID"
    static let heightHeader: CGFloat = 150.0

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    weak var viewModel: FoodViewModel! {
        didSet {
            nameLabel.text = viewModel.name
            photo.loadImageUsingCacheWithURLString(viewModel.imageUrl, placeHolder: nil)
        }
    }
}

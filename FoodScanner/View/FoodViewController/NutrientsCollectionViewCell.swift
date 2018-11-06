//
//  NutrientsCollectionViewCell.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

class NutrientsCollectionViewCell: UICollectionViewCell {
    
    static let cellID = "NutrientsCollectionViewCellID"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var viewModel: FoodViewModel! {
        didSet {
            tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource
extension NutrientsCollectionViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nutrientsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NutrientTableViewCell.cellID, for: indexPath) as? NutrientTableViewCell {
            cell.typeLabel.text = viewModel.getNameNutrient(index:indexPath.row)
            cell.quantityLabel.text = viewModel.getQuantityNutrient(index:indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}


//MARK: - UITableViewDelegate
extension NutrientsCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

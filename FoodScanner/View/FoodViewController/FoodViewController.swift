//
//  FoodViewController.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import UIKit

class FoodViewController: UIViewController {
    
    @IBOutlet weak var desriptionCollectionView: UICollectionView!
    
    fileprivate enum DescriptionTypeCell:Int {
        case descriptionChart = 0
        case descriptionNutrients
        
        static let count: Int = {
            var max: Int = 0
            while let _ = DescriptionTypeCell(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    var viewModel: FoodViewModel! {
        didSet {
            if let desriptionCollectionView = desriptionCollectionView {
                desriptionCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension FoodViewController: UICollectionViewDelegate {
    
}

extension FoodViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DescriptionTypeCell.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        switch indexPath.row {
        case DescriptionTypeCell.descriptionChart.rawValue:
            if let cellChart = desriptionCollectionView.dequeueReusableCell(withReuseIdentifier: ChartCollectionViewCell.cellID, for: indexPath) as? ChartCollectionViewCell {
                cellChart.viewModel = viewModel
                cell = cellChart
            }
        case DescriptionTypeCell.descriptionNutrients.rawValue:
            if let cellNutrients = desriptionCollectionView.dequeueReusableCell(withReuseIdentifier: NutrientsCollectionViewCell.cellID, for: indexPath) as? NutrientsCollectionViewCell {
                cellNutrients.viewModel = viewModel
                cell = cellNutrients
            }
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:UIScreen.main.bounds.size.width,height: FoodCollectionReusableView.heightHeader)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FoodCollectionReusableView.cellID, for: indexPath) as? FoodCollectionReusableView {
                headerView.viewModel = viewModel
                return headerView
            }
        }
        return UICollectionReusableView()
    }
    
}

extension FoodViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero
        if indexPath.row < DescriptionTypeCell.count {
            let width = UIScreen.main.bounds.size.width
            switch indexPath.row {
            case DescriptionTypeCell.descriptionChart.rawValue:
                size = CGSize(width: width, height: ChartCollectionViewCell.heightCell)
            case DescriptionTypeCell.descriptionNutrients.rawValue:
                size = CGSize(width: width, height: viewModel.nutrientsCount == 0 ? NutrientTableViewCell.heightRow: CGFloat(viewModel.nutrientsCount) * NutrientTableViewCell.heightRow)
            default:
                break
            }
        }
        return size
    }
}

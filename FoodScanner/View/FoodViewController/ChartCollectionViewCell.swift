//
//  ChartCollectionViewCell.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit
import Charts


class ChartCollectionViewCell: UICollectionViewCell {
    
    private enum ColorChart: Int {
        case carbohydrates = 0
        case fat
        case fibers
        case protein
        case salt
        case unknown
        
        typealias RawValue = Int
        
        init(rawValue: RawValue) {
            switch rawValue {
            case 0: self = .carbohydrates
            case 1: self = .fat
            case 2: self = .fibers
            case 3: self = .protein
            case 4: self = .salt
            default: self = .unknown
            }
        }
        
        var rawValue: UIColor {
            switch self {
            case .carbohydrates: return #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
            case .fat: return #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            case .fibers: return #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
            case .protein: return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            case .salt: return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            case .unknown: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            }
        }
    }
    
    static let cellID = "ChartCollectionViewCellID"
    static let heightCell: CGFloat = 300.0
    
    @IBOutlet weak var pieChartView : PieChartView!
    
    weak var viewModel: FoodViewModel! {
        didSet {
            self.setChart()
        }
    }
    
    private func setChart() {
        pieChartView.usePercentValuesEnabled = true
        pieChartView.centerText = "FOOD Scanner"
        pieChartView.chartDescription?.text = ""
        pieChartView.noDataText = "No data available"
        pieChartView.legend.enabled = true
        
        let pieChartDataSet = PieChartDataSet(entries: viewModel.nutrientsData, label: viewModel.descriptionChart)
        pieChartDataSet.valueLineVariableLength = true
        pieChartDataSet.xValuePosition = .outsideSlice
        var colors: [UIColor] = []
        viewModel.nutrientsColorIndex.forEach { index  in
            colors.append(ColorChart(rawValue: index).rawValue)
        }
        pieChartDataSet.colors = colors
        pieChartDataSet.sliceSpace = 2

        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        pieChartData.setValueFont(.systemFont(ofSize: 12, weight: .bold))
        pieChartData.setValueTextColor(.black)
        pieChartView.data = pieChartData
        
        pieChartView?.animate(xAxisDuration: 1.4,easingOption: ChartEasingOption.easeOutBack)
    }
}

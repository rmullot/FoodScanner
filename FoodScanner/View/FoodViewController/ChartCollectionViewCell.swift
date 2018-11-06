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
        pieChartView.legend.enabled = false
        pieChartView.setExtraOffsets(left: 20, top: 20, right: 20, bottom: 20)
        
        let pieChartDataSet = PieChartDataSet(values: viewModel.nutrientsData, label: viewModel.descriptionChart)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setValueFont(.systemFont(ofSize: 11, weight: .light))
        pieChartData.setValueTextColor(.black)
        pieChartView.data = pieChartData
        
       
        
        var colors: [UIColor] = []
        
        for _ in 0..<pieChartDataSet.values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.valueLineVariableLength = true
        pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.colors = colors
        pieChartDataSet.sliceSpace = 2
        pieChartView?.animate(xAxisDuration: 1.4,easingOption: ChartEasingOption.easeOutBack)
    }
}

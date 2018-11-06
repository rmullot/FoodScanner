//
//  Tool.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

class Tool {
    
    static func getBestPicture(resolutions:[String])->String {
        let height = Int(UIScreen.main.bounds.size.height)
        var chosenRes :Int = 0
        var chosenResolution :String = ""
        for resolution in resolutions {
            let arrayTmp = resolution.split(separator:"x")
            if arrayTmp.count > 0, let res = Int(arrayTmp[0]){
                let deltaHeight: Int = res - height
                let deltaChosenResolution : Int = res - chosenRes
                if deltaChosenResolution > deltaHeight {
                    chosenRes = res
                    chosenResolution = resolution
                }
            }
        }
        return chosenResolution
    }
    
    static func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString, let url = URL(string: urlString) {
                // check if your application can open the URL instance
                return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}


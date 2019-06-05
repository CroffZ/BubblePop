//
//  BubbleModel.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import Foundation
import UIKit

class BubbleModel: NSObject {
    
    static let red = BubbleModel(color: .red, point: 1)
    static let pink = BubbleModel(color: UIColor(red: 249/255.0, green: 174/255.0, blue: 200/255.0, alpha: 1), point: 2)
    static let green = BubbleModel(color: .green, point: 5)
    static let blue = BubbleModel(color: .blue, point: 8)
    static let black = BubbleModel(color: .black, point: 10)
    
    var color: UIColor
    var point: Int
    
    init(color: UIColor, point: Int) {
        self.color = color
        self.point = point
    }
    
}

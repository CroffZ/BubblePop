//
//  BubbleModel.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import UIKit

struct BubbleModel {

    static let red = BubbleModel(name: "Red", color: .red, point: 1, weight: 40)
    static let pink = BubbleModel(name: "Pink", color: UIColor(red: 249/255.0, green: 174/255.0, blue: 200/255.0, alpha: 1), point: 2, weight: 30)
    static let green = BubbleModel(name: "Green", color: .green, point: 5, weight: 15)
    static let blue = BubbleModel(name: "Blue", color: .blue, point: 8, weight: 10)
    static let black = BubbleModel(name: "Black", color: .black, point: 10, weight: 5)
    static let all = [red, pink, green, blue, black]
    static let totalWeight = all.reduce(0) { $0 + $1.weight }

    let name: String
    let color: UIColor
    let point: Int
    /// Relative spawn chance. The weights of `all` add up to 100.
    let weight: Int

    init(name: String, color: UIColor, point: Int, weight: Int) {
        self.name = name
        self.color = color
        self.point = point
        self.weight = weight
    }

    static func random(roll: Int) -> BubbleModel {
        var threshold = 0
        for bubble in all {
            threshold += bubble.weight
            if roll < threshold {
                return bubble
            }
        }
        return black
    }

}
//
//  BubbleView.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 Croff Zhong. Licensed under the MIT License.
//

import UIKit

class BubbleView: UIButton {

    static let size = 80

    let model: BubbleModel

    init(x: Int, y: Int, model: BubbleModel) {
        self.model = model
        super.init(frame: CGRect(x: x, y: y, width: BubbleView.size, height: BubbleView.size))
        setTitle("", for: .normal)
        backgroundColor = model.color
        layer.cornerRadius = frame.width / 2
        alpha = 0
        isAccessibilityElement = true
        accessibilityLabel = "\(model.name) bubble, \(model.point) points"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("BubbleView is created in code, not from a storyboard.")
    }

    func appear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0.8
        })
    }

    func disappear() {
        guard isUserInteractionEnabled else { return }
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    func pop() {
        guard isUserInteractionEnabled else { return }
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (_) in
            self.removeFromSuperview()
        }
    }

}
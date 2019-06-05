//
//  BubbleView.swift
//  BubblePop
//
//  Created by Croff Zhong on 2019/6/5.
//  Copyright © 2019 BubblePop. All rights reserved.
//

import UIKit

class BubbleView: UIButton {
    
    static let SIZE = 80
    
    var model: BubbleModel
    
    init(x: Int, y: Int, model: BubbleModel) {
        self.model = model
        super.init(frame: CGRect(x: x, y: y, width: BubbleView.SIZE, height: BubbleView.SIZE))
        self.setTitle("", for: .normal)
        self.backgroundColor = model.color
        self.layer.cornerRadius = self.frame.width / 2
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0.8
        })
    }
    
    func disappear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    func pop() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

//
//  FloatingNumberAnimationManager.swift
//  
//
//  Created by Yusuf Demirkoparan on 8.06.2022.
//

import Foundation
import UIKit

class FloatingNumberCounter: FloatingAnimationManager {
    
    init(minValue: Int = 0, maxValue: Int = 9, font: UIFont, textColor: UIColor, backgroundColor: UIColor, scrollDuration: TimeInterval) {
        var numbers = [UILabel]()
        var i = minValue
        var biggestHeight: CGFloat = 0
        var biggestWidth: CGFloat = 0
        
        while i <= maxValue {
            let label = UILabel(frame: CGRect.zero)
            label.text = String(i)
            label.font = font
            label.textAlignment = .center
            label.sizeToFit()
            label.textColor = textColor
            label.backgroundColor = backgroundColor
            
            if label.frame.height > biggestHeight {
                biggestHeight = label.frame.height
            }
            
            if label.frame.width > biggestWidth {
                biggestWidth = label.frame.width
            }
            
            numbers.append(label)
            i += 1
        }
        
        let biggestFrame = CGRect(x: 0, y: 0, width: biggestWidth, height: biggestHeight)
        
        var items = [UIView]()
        for label in numbers {
            let view = UIView(frame: biggestFrame)
            
            label.frame.origin.x = (biggestFrame.width - label.frame.width)/2
            label.frame.origin.y = (biggestFrame.height - label.frame.height)/2
            view.addSubview(label)
            
            items.append(view)
        }
        
        super.init(items: items, frame: biggestFrame)
        self.floatingDuration = scrollDuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

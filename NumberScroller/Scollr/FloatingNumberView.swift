//
//  FloatingNumberCounter.swift
//
//
//  Created by Yusuf Demirkoparan on 8.06.2022.
//

import Foundation
import UIKit

class FloatingNumberView: UIView {
    
    private var model: FloatingNumberConformable
    private var numberScrollers = [FloatingNumberCounter]()
    private let numberScrollerBackgroundColor: UIColor = .clear
    private var isShowComma = false
    private var seperatorView: UIView?
    private var commaView: UIView?
    private var negativeSignView: UIView?
    private var animator: UIViewPropertyAnimator?
    private var numbers: [String]?
    private var negativeSymbol = "-"
    private var slideDuration: TimeInterval = 0.5
    
    // Computed
    private var fadeOutDuration: TimeInterval {
        return slideDuration / 2
    }
    
    private var calCoordinate: CGFloat {
        var startingX: CGFloat = 0
        if let negativeSignView = negativeSignView, model.value < 0 {
            startingX += negativeSignView.frame.width
        }
        return startingX
    }
    
    init(model: FloatingNumberConformable) {
        self.model = model
        super.init(frame: CGRect.zero)
        setupViews(model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeToFit() {
        var width: CGFloat = 0
        
        if let lastNumber = numberScrollers.last {
            width = lastNumber.frame.origin.x + lastNumber.frame.width
        }
        
        self.frame.size.width = width
    }
    
    // Todo
    func getStringArray(value: Double) -> [String] {
        let hasDecimalCharacter = (value - floor(value) > 0.000001)
        let formatter = NumberFormatter()
        let locale = Locale(identifier: "tr_TR")
        formatter.locale = locale
        model.decimalPlaces = hasDecimalCharacter ? 2 : 0
        formatter.maximumFractionDigits = hasDecimalCharacter ? 2 : 0
        formatter.minimumFractionDigits = hasDecimalCharacter ? 2 : 0
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        var array = [String]()
        if let arr = formatter.string(from: NSNumber(value: value)) {
            arr.forEach { character in
                array.append(String(character))
            }
        }
        return array
    }
    
    func setValueToScroller(_ value: Double, animated: Bool = true) {
        model.value = value
        
        var numberString = getStringArray(value: model.value)
        self.numbers = numberString
        if model.decimalPlaces == 0, numberString.contains(model.seperator) {
            while let lastElement = numberString.popLast(), lastElement != model.seperator {
                continue
            }
        }
        
        var numbersOnly = [Int]()
        for entry in numberString {
            if let value = Int(entry) {
                numbersOnly.append(value)
            }
        }
        
        if numbersOnly.count > numberScrollers.count {
            let numberToAdd = numbersOnly.count - numberScrollers.count
            updateNumberScrollers(add: numberToAdd)
        } else if numberScrollers.count > numbersOnly.count {
            let numberToRemove = numberScrollers.count - numbersOnly.count
            updateNumberScrollers(remove: numberToRemove, animated: animated)
        }
        updateNumberScrollers(withNumbers: numbersOnly, animated: animated)
        updateScrollerLayout(animated: animated)
    }
}

fileprivate extension FloatingNumberView {
    func updateNegativeSymbol() {
        guard let animator = self.animator else { return }
        let includeNegativeSign = model.value < 0
        
        if includeNegativeSign {
            if let negativeSignView = negativeSignView, negativeSignView.alpha != 1 {
                animator.addAnimations {
                    negativeSignView.alpha = 1
                }
            } else if negativeSignView == nil {
                let negativeLabel = UILabel()
                negativeLabel.text = negativeSymbol
                negativeLabel.textColor = model.textColor
                negativeLabel.font = model.font
                negativeLabel.sizeToFit()
                negativeLabel.frame.origin = CGPoint.zero
                addSubview(negativeLabel)
                
                negativeLabel.alpha = 0
                negativeSignView = negativeLabel
                animator.addAnimations {
                    negativeLabel.alpha = 1
                }
            }
        } else {
            if let negativeSignView = negativeSignView {
                animator.addAnimations {
                    negativeSignView.alpha = 0
                }
                animator.addCompletion { _ in
                    negativeSignView.removeFromSuperview()
                    self.negativeSignView = nil
                }
            }
        }
    }
    
    private func updateScrollerLayout(animated: Bool) {
        if let animator = self.animator {
            animator.stopAnimation(true)
        }
        
        var animationDuration = slideDuration
        if !animated {
            animationDuration = FloatingAnimationManager.noAnimationDuration
        }
        animator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut, animations: nil)
        updateNegativeSymbol()
        addCommaView()
        addSeperatorView()
        updateNumbersLayout()
        
        animator!.addCompletion({ _ in
            self.animator = nil
        })
        animator!.startAnimation()
    }
    
    func updateNumbersLayout() {
        guard let animator = self.animator else {  return }
        commaView?.isHidden = true
        seperatorView?.isHidden = true
        
        var startingX = calCoordinate
        var numberPadding: CGFloat = .zero
        
        let seperatorLocation = numberScrollers.count - model.decimalPlaces
        let commaIndex = numbers?.firstIndex(where: { $0 == "." }) ?? .zero
        let decimalIndex = numbers?.firstIndex(where: { $0 == "," }) ?? .zero
        
        for (index, scroller) in numberScrollers.enumerated() {
            
            if scroller.superview == nil {
                addSubview(scroller)
                scroller.frame.origin.x = .zero
                scroller.alpha = .zero
            }
            var x: CGFloat = .zero
            
            startingX = CGFloat(index)
            x = startingX + (CGFloat(index)) * scroller.frame.size.width
            if numberPadding == .zero {
                numberPadding = round(x)
            }
            
            if index >= Int(commaIndex) && commaIndex != 0,
               let _ = commaView {
                x += numberPadding/2
            }
            
            if index >= seperatorLocation, let _ = seperatorView {
                x += numberPadding/2
            }
            
            animator.addAnimations {
                scroller.alpha = 1
                scroller.frame.origin.x = x
            }
            
            if index == commaIndex && commaIndex != 0, let commaView = commaView {
                commaView.isHidden = false
                animator.addAnimations {
                    commaView.alpha = 1
                    commaView.frame.origin.x = x-numberPadding
                }
            }
            
            if index == seperatorLocation && (decimalIndex) > 0 , let seperatorView = seperatorView {
                seperatorView.isHidden = false
                animator.addAnimations {
                    seperatorView.alpha = 1
                    seperatorView.frame.origin.x = (x+numberPadding/2)-numberPadding
                }
            }
        }
    }
}

fileprivate extension FloatingNumberView {
    func addCommaView() {
        guard commaView == nil else { return }
        let seperatorLabel = UILabel()
        seperatorLabel.text = "."
        seperatorLabel.textColor = model.textColor
        seperatorLabel.font = model.font
        seperatorLabel.sizeToFit()
        seperatorLabel.frame.size.width += 2 * model.seperatorSpacing
        seperatorLabel.textAlignment = .center
        seperatorLabel.frame.origin = CGPoint.zero
        addSubview(seperatorLabel)
        seperatorLabel.alpha = 0
        commaView = seperatorLabel
    }
    
    func addSeperatorView() {
        guard model.decimalPlaces > 0, seperatorView == nil else { return }
        let seperatorLabel = UILabel()
        seperatorLabel.text = model.seperator
        seperatorLabel.textColor = model.textColor
        seperatorLabel.font = model.font
        seperatorLabel.sizeToFit()
        seperatorLabel.frame.size.width += 2
        seperatorLabel.textAlignment = .center
        seperatorLabel.frame.origin = CGPoint.zero
        addSubview(seperatorLabel)
        seperatorLabel.alpha = 0
        seperatorView = seperatorLabel
    }
}

fileprivate extension FloatingNumberView {
    func updateNumberScrollers(withNumbers numbers: [Int], animated: Bool) {
        if numbers.count == numberScrollers.count {
            for (index, scroller) in numberScrollers.enumerated() {
                scroller.scrollToItem(atIndex: numbers[index], animated: animated)
            }
        }
    }
    
    func updateNumberScrollers(remove numberCount: Int, animated: Bool) {
        var animationDuration = fadeOutDuration
        if !animated {
            animationDuration = FloatingAnimationManager.noAnimationDuration
        }
        
        for index in 0..<numberCount {
            let scroller = numberScrollers[0]
            let leftShift = CGFloat(index) * scroller.frame.width * -1
            
            numberScrollers.remove(at: 0)
            UIView.animate(withDuration: animationDuration,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                scroller.alpha = 0
                scroller.frame.origin.x += leftShift
            }) { _ in
                scroller.removeFromSuperview()
            }
        }
    }
    
    func updateNumberScrollers(add count: Int) {
        var newScrollers = [FloatingNumberCounter]()
        for _ in 0..<count {
            let floatingCounter = FloatingNumberCounter(font: model.font, textColor: model.textColor, backgroundColor: numberScrollerBackgroundColor, scrollDuration: model.scrollDuration)
            newScrollers.append(floatingCounter)
        }
        numberScrollers.insert(contentsOf: newScrollers, at: 0)
    }
}

extension FloatingNumberView {
    private func setupViews(_ model: FloatingNumberConformable) {
        clipsToBounds = false
        setValueToScroller(model.value, animated: model.animateInitialValue)
        frame.size.height = numberScrollers.first!.frame.size.height
        sizeToFit()
    }
}

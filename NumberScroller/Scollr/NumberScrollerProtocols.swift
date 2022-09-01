//
//  NumberScrollerProtocols.swift
//  NumberScroller
import UIKit

protocol FloatingNumberConformable {
    var value: Double { get set }
    var scrollDuration: TimeInterval { get set }
    var decimalPlaces: Int { get set }
    var seperator: String { get }
    var seperatorSpacing: CGFloat { get }
    var font: UIFont { get }
    var textColor: UIColor { get }
    var animateInitialValue: Bool { get }
}

struct ScrollAmountModel: FloatingNumberConformable {
    var value: Double
    var scrollDuration: TimeInterval = 0.3
    var decimalPlaces: Int = 0
    var seperator: String = ","
    var seperatorSpacing: CGFloat = 0
    var font: UIFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    var textColor: UIColor = .black
    var animateInitialValue: Bool = true
}

enum FloatingDirection {
    case down
    case up
    
    var state: Int {
        switch self {
        case .down:
            return 1
        case .up:
            return -1
        }
    }
}

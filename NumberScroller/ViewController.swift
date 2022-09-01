//
//  ViewController.swift
//  NumberScroller
//
//  Created by Yusuf Demirkoparan on 8.06.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      let ss =  ScrollAmountModel(value: 0,
                                  scrollDuration: 1.5,
                                  decimalPlaces: 2,
                                  seperator: ",",
                                  seperatorSpacing: 8,
                                  font: UIFont.systemFont(ofSize: 22),
                                  textColor: .red,
                                  animateInitialValue: true)
        let numberCounter = FloatingNumberView(model: ss)
        numberCounter.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
        numberCounter.setValueToScroller(1232.10)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            numberCounter.setValueToScroller(32322.2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            numberCounter.setValueToScroller(412637.54)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13) {
            numberCounter.setValueToScroller(32322.2)
        }
        view.addSubview(numberCounter)
        
        numberCounter.center = view.center
    }
}


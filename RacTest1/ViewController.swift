//
//  ViewController.swift
//  RacTest1
//
//  Created by Nahuel Marisi on 2016-06-19.
//  Copyright © 2016 TechBrewers. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var lowercaseTextField: UITextField!
    @IBOutlet weak var capsLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
   
    private var isThrottling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Observing as timer signal for 10 events.
        timerSignal()
            .take(10)
            .observeNext { [unowned self] next in
                self.countLabel.text = next
        }
        
        // 2a. Lowercase to uppercase.
        lowerToUpperSignal()
            .takeUntil(self.rac_WillDeallocSignalProducer())
            .throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            .startWithNext { [unowned self] next in
                self.capsLabel.text = next
        }
        
        // 2b. Alterative implementation of lowercase to uppercase without RAC.
        // Uncomment to use, and comment 2a.
        //configureAlternativeToUppercase()
        
        // 3. Phone signal
       phoneSignalProducer()
           .startWithNext { [unowned self] next in
                self.phoneLabel.text = "YES"
        }
        
    }
    
   
    // 1. timer signal
    func timerSignal() -> Signal<String, NoError> {
        var counter: Int = 1
        
       // Signal must return disposable?
        return Signal { observer in
            
            NSTimer.schedule(repeatInterval: 1.0) { _ in
                observer.sendNext("Counter: \(counter)")
                counter += 1
                
            }
            return nil
        }
    }
    
    // 2. lower case to upper case
    func lowerToUpperSignal() -> SignalProducer<String, NSError> {
        
        return lowercaseTextField
            .rac_textSignal()
            .toSignalProducer()
            .map { next in
                guard let string = next else {
                    return ""
                }
                return string.uppercaseString
            }
   }
    
    // 3. Phone text field
    func phoneSignalProducer() -> SignalProducer<Bool, NSError> {
        
        return phoneTextField
            .rac_textSignal()
            .toSignalProducer()
            .filter { next in
                guard let string = next else {
                    return false
                }
                return string.hasPrefix("07")
        }
            .map {_ in
                return true
        }
    }
    
    // MARK: - Alternative to signals for uppercase string
    private func configureAlternativeToUppercase() {
        lowercaseTextField.addTarget(self,
                                     action: #selector(textFieldDidChange(_:)),
                                     forControlEvents: .EditingChanged)
        
        NSTimer.scheduledTimerWithTimeInterval(0.5,
                                               target: self,
                                               selector: #selector(throttleTimer),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    func throttleTimer(timer: NSTimer) {
        isThrottling = false
        
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        if isThrottling {
            return
        }
        
        capsLabel.text = textField.text?.uppercaseString
        isThrottling = true
    }
    
   
   

 

}


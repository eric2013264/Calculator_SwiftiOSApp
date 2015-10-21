//
//  ViewController.swift
//  Calculator
//
//  Created by Eric Chen on 6/8/15.
//  Copyright (c) 2015 ericchen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func appendPoint(sender: UIButton) {
        if display.text!.rangeOfString(".") == nil {
            appendDigit(sender)
        }
    }

    @IBAction func backSpace() {
        if (display.text!).characters.count > 1 {
            display.text = String(dropLast((display.text!).characters))
        } else {
            display.text = "0"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            displayValue = displayValue! * -1
            userIsInTheMiddleOfTypingANumber = true
        } else {
            displayValue = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.pushOperand(displayValue!)
    }
    
    var displayValue: Double? {
        get {
            var returnValue: Double?
            if let displayText = display.text {
                if let numberFromString = NSNumberFormatter().numberFromString(displayText) {
                    returnValue = numberFromString.doubleValue
                } else {
                    print("numberFromString was nill. displayText = \(displayText)")
                }
            } else {
                print("displayText was nill")
            }
            
            return returnValue
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                display.text = "0"
            }
            
            history.text = brain.description + " ="
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clearAll() {
        brain.clear()
        display.text = "0"
        history.text = ""
        userIsInTheMiddleOfTypingANumber = false
    }
}


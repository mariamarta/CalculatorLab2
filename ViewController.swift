//
//  ViewController.swift
//  Calculator3
//
//  Created by Marta Malapitan on 2/23/17.
//  Copyright © 2017 Marta Malapitan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
            let textCurrentlyInHistory = history.text!
            history.text = textCurrentlyInHistory + digit
        } else {
            display.text = digit
            history.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
       if let mathematicalSymbol = sender.currentTitle {
        brain.performOperation(symbol: mathematicalSymbol)
            history.text = history.text! + mathematicalSymbol
        }
        displayValue = brain.result
    }
    
    @IBAction private func memoryOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let memoryOp = sender.currentTitle {
            brain.memoryOperation(symbol: memoryOp)
            history.text = history.text! + memoryOp
        }
        displayValue = brain.result
    }
    
    
    private var decimalIsPressed = false
    
    @IBAction private func decimal(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = true
        if decimalIsPressed == false {
            display.text = display.text! + "."
            decimalIsPressed = true
        }
    }
    
}


//
//  CalculatorBrain.swift
//  Calculator3
//
//  Created by Marta Malapitan on 2/25/17.
//  Copyright © 2017 Marta Malapitan. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    private var accumulator = 0.0
    private var memory = 0.0
    private var count = 0
    private var progressHistory = Int.max
    var memoryValue = 0.0
    var variableValues = Dictionary<String, Double>()
    
    func setOperand(operand: Double) {
        accumulator = operand
        historyDisplay = String(format:"%g", operand)
        memoryValue = memory
    }
    
    func setOperand(variableName: String){
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumulator = variableValues[variableName]!
        historyDisplay = variableName
    }
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) ->String, Int)
        case Equals
        case Clear
        case MemoryClear((Double) -> Double)
    }
    
        var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "±": Operation.UnaryOperation({-$0}, {"-(\($0)"}),
        "√"  : Operation.UnaryOperation(sqrt, {"√(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, {"cos(\($0))"}),
        "sin" : Operation.UnaryOperation(sin, {"sin(\($0))"}),
        "tan" : Operation.UnaryOperation(tan, {"tan(\($0))"}),
        "×" : Operation.BinaryOperation({$0 * $1}, {"\($0)*\($1)"}, 1),
        "÷" : Operation.BinaryOperation({$0 / $1}, {"\($0)/\($1)"}, 1),
        "+" : Operation.BinaryOperation({$0 + $1}, {"\($0)+\($1)"}, 0),
        "−" : Operation.BinaryOperation({$0 - $1}, {"\($0)-\($1)"}, 0),
        "x²" : Operation.UnaryOperation({$0 * $0}, {"\($0)*\($0)"}),
        "=" : Operation.Equals,
        "Clear" : Operation.Clear
    ]
    
    func memoryOperation(symbol: String){
        let operation = symbol
        switch operation {
           //Memory Clear
            case "MC":
            memory = 0
            memoryValue = 0.0
           //Memory Store
            case "MS":
            memory = accumulator
            memoryValue = accumulator
           //Memory Restore
            case "MR":
                if memory != 0{
                    accumulator = memory
                    historyDisplay = String("MR(\(memory))")
            }
           //Memory Plus
            case "M+":
                if memory != 0{
                    memory += accumulator
                    memoryValue = Double(memory)
            }
            default: break
        }
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation{
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation (let function, let historyFunction):
                accumulator = function(accumulator)
                historyDisplay = historyFunction(historyDisplay)
            case .BinaryOperation(let function, let historyFunction, let current): executePendingBinaryOperation()
            if progressHistory < current{
                historyDisplay = "(\(historyDisplay))"
                }
            pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, historyFunction: historyFunction, historyOperand: historyDisplay)
            case .Equals: executePendingBinaryOperation()
            case .Clear:
                clear()
            default: break
            }
        }
    }
    
    /*  First click clears accumulator value
        Second click clears all values besides memory value     */
    private func clear(){
        if count == 0{
            count += 1
            accumulator = 0
        } else {
            accumulator = 0
            historyDisplay = ""
            count = 0
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            historyDisplay = pending!.historyFunction(pending!.historyOperand, historyDisplay)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var historyFunction: (String, String) -> String
        var historyOperand: String
    }
    
    private var historyDisplay = ""{
        didSet{
            if pending == nil{
                progressHistory = Int.max
            }
        }
    }
    
    //Allows View Controller to get result and history from brain
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var history: String{
        get{
            if pending == nil{
                return historyDisplay
            } else {
                return pending!.historyFunction(pending!.historyOperand, pending!.historyOperand != historyDisplay ? historyDisplay: "")
            }
        }
    }
}


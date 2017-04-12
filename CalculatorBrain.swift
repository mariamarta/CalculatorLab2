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
    private var internalProgram = [Any]()
    private var memoryConstant = 0.0
    
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
        var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±": Operation.UnaryOperation({-$0}),
        "√"  : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "−" : Operation.BinaryOperation({$0 - $1}),
        "x²" : Operation.UnaryOperation({$0 * $0}),
        "=" : Operation.Equals,
            "Clear" : Operation.Clear
    ]
    
    func memoryOperation(symbol: String){
        let operation = symbol
        switch operation {
            case "MC": memoryConstant = 0
                        pending = nil
            case "MS": memoryConstant = accumulator
            case "MR": accumulator = memoryConstant
            case "M+": memoryConstant = memoryConstant + accumulator
            default: break
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation{
            case .Constant(let value): accumulator = value
            case .UnaryOperation (let function): accumulator = function(accumulator)
            case .BinaryOperation(let function): executePendingBinaryOperation()
            pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals: executePendingBinaryOperation()
            case .Clear:
                accumulator = 0.0
                pending = nil
            }
        }
    }
    
    private func clear(){
            accumulator = 0
            pending = nil
            internalProgram.removeAll()
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    typealias PropertyList = Any
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [Any]{
                for op in arrayOfOps {
                    if let operand = op as? Double{
                        setOperand(operand: operand)
                    } else if let operation = op as? String{
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
 

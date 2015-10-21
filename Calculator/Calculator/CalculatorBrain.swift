//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Eric Chen on 6/22/15.
//  Copyright (c) 2015 ericchen. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .Constant(let symbol, _):
                    return "\(symbol)"
                }
            }
        }
    }
    
    var variableValues = Dictionary<String,Double>()
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", Int.max, *))
        learnOp(Op.BinaryOperation("÷", Int.max) { $1 / $0 })
        learnOp(Op.BinaryOperation("+", 1, +))
        learnOp(Op.BinaryOperation("-", 1) { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("ᐩ/-") { $0 * -1 })
        learnOp(Op.Constant("π", M_PI))
    }
    
    var description: String {
        get {
            var description = ""
            var evaluation = evaluateDescription(opStack)
            while(evaluation.result != "?") {
                description = "\(evaluation.result), \(description)"
                evaluation = evaluateDescription(evaluation.remainingOps)
            }
            
            let lastIndex = advance(description.endIndex, -2)
            return description[description.startIndex..<lastIndex]
        }
    }
    
    func clear() {
        opStack = [Op]()
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let constant):
                return (constant, remainingOps)
            }
        }
        
        return (nil, ops)
    }
    
    
    private func evaluateDescription(ops: [Op]) -> (result: String, opPrecedence: Int, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .UnaryOperation(let symbol, _):
                let description = evaluateDescription(remainingOps)
                return ("\(symbol)(\(description.result))", Int.max, description.remainingOps)
            case .BinaryOperation(let symbol, let precedence,  _):
                let evaluation = evaluateDescription(remainingOps)
                let evaluation2 = evaluateDescription(evaluation.remainingOps)
                let evaluationsPrecedenceIsLower = evaluation.opPrecedence < precedence
                if evaluationsPrecedenceIsLower {
                    return ("\(evaluation2.result) " + symbol + " (\(evaluation.result))", precedence, evaluation2.remainingOps)
                } else {
                    return ("\(evaluation2.result) " + symbol + " \(evaluation.result)", precedence, evaluation2.remainingOps)
                }
            case .Operand(let operand):
                return ("\(operand)", Int.max, remainingOps)
            case .Constant(let constant, _):
                return ("\(constant)", Int.max, remainingOps)
            }
        }
        
        return ("?", Int.max, ops)
    }
}
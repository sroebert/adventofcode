import Foundation

struct Assignment202018: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var total: UInt64 = 0
        try await getStreamedInput { line in
            let expression = try parseExpression(from: line)
            total += expression.evaluate()
        }
        return total
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var total: UInt64 = 0
        try await getStreamedInput { line in
            let expression = try parseExpression(from: line, precedence: [
                .add: 1,
                .multiply: 0
            ])
            total += expression.evaluate()
        }
        return total
    }
    
    // MARK: - Utils
    
    private indirect enum Expression {
        case value(UInt64)
        case operation(Expression, Operation, Expression)
        
        func evaluate() -> UInt64 {
            switch self {
            case .value(let value):
                return value
                
            case .operation(let leftExpression, let operation, let rightExpression):
                let leftValue = leftExpression.evaluate()
                let rightValue = rightExpression.evaluate()
                return operation.process(leftValue: leftValue, rightValue: rightValue)
            }
        }
    }
    
    private enum Operation: String, CaseIterable {
        case add = "+"
        case multiply = "*"
        
        func process(leftValue: UInt64, rightValue: UInt64) -> UInt64 {
            switch self {
            case .add:
                return leftValue + rightValue
            case .multiply:
                return leftValue * rightValue
            }
        }
    }
    
    private func parsePartialExpression(from scanner: Scanner, precedence: [Operation: Int]) throws -> Expression {
        if let value = scanner.scanUInt64() {
            return .value(value)
        } else if scanner.scanString("(") != nil {
            return try parseExpression(from: scanner, precedence: precedence)
        } else {
            throw InputError(message: "Invalid input")
        }
    }
    
    private func parseOperation(from scanner: Scanner) throws -> Operation {
        for operation in Operation.allCases {
            if scanner.scanString(operation.rawValue) != nil {
                return operation
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    private func isExpressionAtEnd(from scanner: Scanner) -> Bool {
        return scanner.isAtEnd || scanner.scanString(")") != nil
    }
    
    private func parseExpression(from scanner: Scanner, precedence: [Operation: Int]) throws -> Expression {
        var expressions: [Expression] = try [parsePartialExpression(from: scanner, precedence: precedence)]
        var operations: [Operation] = []
        
        while !isExpressionAtEnd(from: scanner) {
            try operations.append(parseOperation(from: scanner))
            try expressions.append(parsePartialExpression(from: scanner, precedence: precedence))
        }
        
        while expressions.count > 2 {
            let leftPrecedence = precedence[operations[0]] ?? 0
            let rightPrecedence = precedence[operations[1]] ?? 0
            
            if rightPrecedence > leftPrecedence {
                let leftExpression = expressions[1]
                let rightExpression = expressions[2]
                let operation = operations.remove(at: 1)
                
                expressions.remove(at: 2)
                expressions[1] = .operation(leftExpression, operation, rightExpression)
            } else {
                let leftExpression = expressions[0]
                let rightExpression = expressions[1]
                let operation = operations.remove(at: 0)
                
                expressions.remove(at: 1)
                expressions[0] = .operation(leftExpression, operation, rightExpression)
            }
        }
        
        if expressions.count == 2 {
            return .operation(expressions[0], operations[0], expressions[1])
        }
        return expressions[0]
    }
    
    private func parseExpression(from expression: String, precedence: [Operation: Int] = [:]) throws -> Expression {
        let scanner = Scanner(string: expression)
        return try parseExpression(from: scanner, precedence: precedence)
    }
}

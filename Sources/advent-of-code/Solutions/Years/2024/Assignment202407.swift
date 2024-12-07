import Foundation

struct Assignment202407: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let equations = try await getEquations()
        return await equations.concurrentCount {
            $0.canBeSolved(includeConcatination: false) ? $0.result : 0
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let equations = try await getEquations()
        return await equations.concurrentCount {
            $0.canBeSolved(includeConcatination: true) ? $0.result : 0
        }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
//    var isSlowInRelease: Bool {
//        return true
//    }
    
    // MARK: - Utils
    
    private struct Equation {
        var result: Int
        var numbers: [Int]
        
        private var operationCount: Int {
            numbers.count - 1
        }
        
        private func calculateResult(multipliers: Int, concatinations: Int = 0) -> Int {
            var total = numbers[0]
            
            var index = 0
            while index < numbers.count - 1 && total - operationCount < result {
                let offsetFlag = (1 << index)
                if (multipliers & offsetFlag) != 0 {
                    total *= numbers[index + 1]
                } else if (concatinations & offsetFlag) != 0 {
                    let multiplier = Int(pow(10, floor(log10(Double(numbers[index + 1]))) + 1))
                    total = total * multiplier + numbers[index + 1]
                } else {
                    total += numbers[index + 1]
                }
                
                index += 1
            }
            
            return total
        }
        
        private func enumeratePossibleSolutions(
            _ possibleSolution: Int,
            execute: (Int) -> Bool
        ) -> Bool {
            // Ignore possibilities that are considered by other solutions
            let offset = (0..<operationCount).reversed().first {
                possibleSolution & (1 << $0) != 0
            } ?? -1
            
            for index in (offset + 1)..<operationCount {
                guard (possibleSolution & (1 << index)) == 0 else {
                    continue
                }
                
                let newPossibleSolution = possibleSolution | (1 << index)
                if execute(newPossibleSolution) {
                    return true
                }
            }
            
            return false
        }
        
        private func canBeSolvedWithConcatination(multipliers: Int) -> Bool {
            var possibleSolutions = [0]
            possibleSolutions.reserveCapacity((1...numbers.count).reduce(0, *))
            
            while !possibleSolutions.isEmpty {
                let possibleSolution = possibleSolutions.removeFirst()
                
                let didFindSolution = enumeratePossibleSolutions(possibleSolution) { newPossibleSolution in
                    let solutionResult = calculateResult(multipliers: multipliers, concatinations: newPossibleSolution)
                    guard solutionResult != result else {
                        return true
                    }
                    
                    if solutionResult - operationCount < result {
                        possibleSolutions.append(newPossibleSolution)
                    }
                    return false
                }
                
                guard !didFindSolution else {
                    return true
                }
            }
            
            return false
        }
        
        func canBeSolved(includeConcatination: Bool) -> Bool {
            let sum = numbers.reduce(0, +)
            guard sum != result else {
                return true
            }
            
            guard sum - operationCount < result else {
                return false
            }
            
            var possibleSolutions = [0]
            possibleSolutions.reserveCapacity((1...numbers.count).reduce(0, *))
            
            while !possibleSolutions.isEmpty {
                let possibleSolution = possibleSolutions.removeFirst()
                
                if includeConcatination && canBeSolvedWithConcatination(multipliers: possibleSolution) {
                    return true
                }
                
                let didFindSolution = enumeratePossibleSolutions(possibleSolution) { newPossibleSolution in
                    let solutionResult = calculateResult(multipliers: newPossibleSolution)
                    guard solutionResult != result else {
                        return true
                    }
                    
                    if solutionResult - operationCount < result {
                        possibleSolutions.append(newPossibleSolution)
                    }
                    return false
                }
                
                guard !didFindSolution else {
                    return true
                }
            }
            
            return false
        }
    }
    
    private func getEquations() async throws -> [Equation] {
        try await mapInput() { line in
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else {
                throw InputError(message: "Invalid input")
            }
            
            let result = Int(parts[0]) ?? 0
            let numbers = parts[1].split(separator: " ").compactMap { Int($0) }
            return Equation(result: result, numbers: numbers)
        }
    }
}

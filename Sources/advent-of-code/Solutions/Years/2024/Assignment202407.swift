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
    
    // MARK: - Utils
    
    private struct Equation {
        var result: Int
        var numbers: [Int]
        
        func canBeSolved(includeConcatination: Bool) -> Bool {
            var paths = [(result, numbers)]
            paths.reserveCapacity((1...numbers.count).reduce(0, *))
            
            while !paths.isEmpty {
                var (pathValue, pathNumbers) = paths.removeFirst()
                guard pathNumbers.count > 1 else {
                    if pathValue == pathNumbers[0] {
                        return true
                    }
                    continue
                }
                
                let nextValue = pathNumbers.removeLast()
                
                // Addition
                if nextValue < pathValue {
                    paths.append((pathValue - nextValue, pathNumbers))
                }
                
                // Multiplication
                let division = pathValue / nextValue
                if division * nextValue == pathValue {
                    paths.append((division, pathNumbers))
                }
                
                // Concatination
                if includeConcatination {
                    let digitCount = floor(log10(Double(nextValue))) + 1
                    let multiplier = Int(pow(10, digitCount))
                    let splitValue = (pathValue - nextValue) / multiplier
                    if splitValue * multiplier + nextValue == pathValue {
                        paths.append((splitValue, pathNumbers))
                    }
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

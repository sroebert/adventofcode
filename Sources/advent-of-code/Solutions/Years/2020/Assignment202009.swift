struct Assignment202009: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let numbers = try await getNumbers()
        return try getInvalidNumber(from: numbers, preambleSize: 25)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let numbers = try await getNumbers()
        let invalidNumber = try getInvalidNumber(from: numbers, preambleSize: 25)
        
        for i in 0..<numbers.count - 1 {
            var count = numbers[i]
            var j = i+1
            
            while count < invalidNumber && j < numbers.count {
                count += numbers[j]
                j += 1
            }
            
            if count == invalidNumber {
                let sortedNumbers = numbers[i..<j].sorted()
                return sortedNumbers[0] + sortedNumbers[sortedNumbers.count - 1]
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    // MARK: - Utils
    
    private func getNumbers() async throws -> [Int] {
        return try await getInput()
            .split(separator: "\n")
            .compactMap { Int($0) }
    }
    
    private func getInvalidNumber(from numbers: [Int], preambleSize: Int) throws -> Int {
        var preamble: [Int] = []
        
        for number in numbers {
            defer {
                preamble.append(number)
                if preamble.count > preambleSize {
                    preamble.removeFirst()
                }
            }
            
            if preamble.count < preambleSize {
                continue
            }
            
            var foundCombination: Bool = false
            outerLoop: for i in 0..<preambleSize-1 {
                for j in i+1..<preambleSize {
                    if preamble[i] != preamble[j] && preamble[i] + preamble[j] == number {
                        foundCombination = true
                        break outerLoop
                    }
                }
            }
            
            if !foundCombination {
                return number
            }
        }
        
        throw InputError(message: "Invalid input")
    }
}

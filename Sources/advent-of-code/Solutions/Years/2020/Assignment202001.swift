struct Assignment202001: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let numbers = try await compactMapInput { Int($0) }.sorted()
        for firstNumber in numbers {
            let secondNumber = 2020 - firstNumber
            
            let index = numbers.binarySearch { $0 < secondNumber }
            if index < numbers.count && numbers[index] == secondNumber {
                return firstNumber * secondNumber
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let numbers = try await getInput()
            .split(separator: "\n")
            .compactMap { Int($0) }
            .sorted()
        
        for i in  0..<numbers.count - 2 {
            for j in i..<numbers.count - 1 {
                let thirdNumber = 2020 - numbers[i] - numbers[j]
                guard thirdNumber >= numbers[j] else {
                    continue
                }
                
                let index = numbers.binarySearch { $0 < thirdNumber }
                if index < numbers.count && numbers[index] == thirdNumber {
                    return numbers[i] * numbers[j] * thirdNumber
                }
            }
        }
        
        throw InputError(message: "Invalid input")
    }
}

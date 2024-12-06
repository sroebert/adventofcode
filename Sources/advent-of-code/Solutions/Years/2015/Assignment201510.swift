struct Assignment201510: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var numbers = try await getNumbers()
        for _ in 0..<40 {
            numbers = process(numbers)
        }
        return numbers.count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var numbers = try await getNumbers()
        for _ in 0..<50 {
            numbers = process(numbers)
        }
        return numbers.count
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func getNumbers() async throws -> [Int] {
        return try await getInput().compactMap { Int(String($0)) }
    }
    
    private func process(_ array: [Int]) -> [Int] {
        guard var number = array.first else {
            return array
        }
        
        var newArray: [Int] = []
        newArray.reserveCapacity(array.count)
        
        var count = 1
        
        for nextNumber in array[1...] {
            if nextNumber == number {
                count += 1
            } else {
                newArray.append(count)
                newArray.append(number)
                
                number = nextNumber
                count = 1
            }
        }
        
        newArray.append(count)
        newArray.append(number)
        
        return newArray
    }
}

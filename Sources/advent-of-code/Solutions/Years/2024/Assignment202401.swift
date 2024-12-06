struct Assignment202401: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let listsNumbers = try await getInputListsNumbers()
        
        let leftList = listsNumbers.mapAndSort(\.left)
        let rightList = listsNumbers.mapAndSort(\.right)
        
        return zip(leftList, rightList)
            .map { abs($0 - $1) }
            .reduce(0, +)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let listsNumbers = try await getInputListsNumbers()
        let rightList = listsNumbers.mapAndSort(\.right)
        
        return listsNumbers.reduce(0) { total, numbers in
            if let firstRightIndex = rightList.firstIndex(of: numbers.left) {
                let lastRightIndex = rightList[firstRightIndex...].firstIndex(where: { $0 != numbers.left }) ?? rightList.endIndex
                return total + numbers.left * (lastRightIndex - firstRightIndex)
            }
            
            return total
        }
    }
    
    // MARK: - Utils
    
    private func getInputListsNumbers() async throws -> [(left: Int, right: Int)]{
        try await mapInput { line in
            let parts = line.split(whereSeparator: \.isWhitespace)
            guard
                parts.count == 2,
                let leftNumber = Int(parts[0]),
                let rightNumber = Int(parts[1])
            else {
                throw InputError(message: "Invalid input line: \(line)")
            }
            
            return (left: leftNumber, right: rightNumber)
        }
    }
}

struct Assignment201501: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let input = try await getInput()
        let downCount = input.count { $0 == ")" }
        return input.count - downCount * 2
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var index = 1
        var floor = 0
        for character in try await getInput() {
            floor += character == "(" ? 1 : -1
            if floor < 0 {
                break
            }
            index += 1
        }
        return index
    }
}

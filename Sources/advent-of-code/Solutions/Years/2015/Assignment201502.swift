struct Assignment201502: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getBoxes().reduce(0) { squareFeet, box in
            let side1 = box.length * box.width
            let side2 = box.width * box.height
            let side3 = box.length * box.height
            let boxSize = 2 * side1 + 2 * side2 + 2 * side3 + min(side1, side2, side3)
            return squareFeet + boxSize
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await getBoxes().reduce(0) { totalLength, box in
            let lengths = [box.length, box.width, box.height].sorted()
            let ribbonLength = lengths[0] * 2 + lengths[1] * 2 +
                box.length * box.width * box.height
            return totalLength + ribbonLength
        }
    }
    
    // MARK: - Utils
    
    private struct Box {
        var length: Int
        var width: Int
        var height: Int
    }
    
    private func getBoxes() async throws -> [Box] {
        return try await getInput()
            .split(separator: "\n")
            .compactMap { line -> Box? in
                let numbers = line.split(separator: "x").compactMap { Int($0) }
                guard numbers.count == 3 else {
                    return nil
                }
                return Box(
                    length: numbers[0],
                    width: numbers[1],
                    height: numbers[2]
                )
            }
    }
}

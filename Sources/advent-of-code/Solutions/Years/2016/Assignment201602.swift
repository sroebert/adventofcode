struct Assignment201602: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        return determineCode(keyPad: expectedKeyPad, instructions: instructions)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        return determineCode(keyPad: actualKeyPad, instructions: instructions)
    }
    
    // MARK: - Utils
    
    private typealias KeyPad = [[String]]
    
    private let expectedKeyPad: KeyPad = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]
    
    private let actualKeyPad: KeyPad = [
        ["",   "", "1",  "",  ""],
        ["",  "2", "3", "4",  ""],
        ["5", "6", "7", "8", "9"],
        ["",  "A", "B", "C",  ""],
        ["",   "", "D",  "",  ""],
    ]
    
    private func startingPosition(keyPad: KeyPad) -> Point? {
        for (y, row) in keyPad.enumerated() {
            for (x, button) in row.enumerated() {
                if button == "5" {
                    return Point(x: x, y: y)
                }
            }
        }
        return nil
    }
    
    private func determineCode(keyPad: KeyPad, instructions: [[CardinalDirection]]) -> String {
        guard var position = startingPosition(keyPad: keyPad) else {
            return ""
        }
        
        let rowRange = keyPad.indices
        let columnRange = keyPad[0].indices
        
        var code = ""
        
        for nextButtonInstructions in instructions {
            for instruction in nextButtonInstructions {
                let nextPosition = position + instruction.step
                if rowRange.contains(nextPosition.y),
                    columnRange.contains(nextPosition.x),
                    !keyPad[nextPosition.y][nextPosition.x].isEmpty {
                    position = nextPosition
                }
            }
            
            code += String(keyPad[position.y][position.x])
        }
        
        return code
    }
    
    private func getInstructions() async throws -> [[CardinalDirection]] {
        try await mapInput { line in
            try line.compactMap {
                switch $0 {
                case "U": .north
                case "D": .south
                case "L": .west
                case "R": .east
                default: throw InputError(message: "Invalid input")
                }
            }
        }
    }
}

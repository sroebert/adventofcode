struct Assignment201601: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        
        var position = Point(x: 0, y: 0)
        var direction: CardinalDirection = .north
        
        for instruction in instructions {
            instruction.move(from: &position, in: &direction)
        }
        
        return abs(position.x) + abs(position.y)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        
        var position = Point(x: 0, y: 0)
        var direction: CardinalDirection = .north
        
        var visitedLocations = Set([position])
        
        for instruction in instructions {
            let distanceToMove: Int
            switch instruction {
            case .left(let distance):
                direction.rotateLeft()
                distanceToMove = distance

            case .right(let distance):
                direction.rotateRight()
                distanceToMove = distance
            }
            
            for _ in 0..<distanceToMove {
                position += direction.step
                guard visitedLocations.insert(position).inserted else {
                    return abs(position.x) + abs(position.y)
                }
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    // MARK: - Utils
    
    private enum Instruction {
        case left(Int)
        case right(Int)
        
        func move(from position: inout Point, in direction: inout CardinalDirection) {
            switch self {
            case .left(let distance):
                direction.rotateLeft()
                position += direction.step * distance
                
            case .right(let distance):
                direction.rotateRight()
                position += direction.step * distance
            }
        }
    }
    
    private func getInstructions() async throws -> [Instruction] {
        let regex = /(?<direction>R|L)(?<distance>\d+)/
        return try await mapInput(separator: ",") { part in
            guard let match = part.firstMatch(of: regex) else {
                throw InputError(message: "Invalid input")
            }
            
            let distance = Int(match.output.distance) ?? 0
            return match.output.direction == "L" ? .left(distance) : .right(distance)
        }
    }
}

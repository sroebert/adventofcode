struct Assignment202012: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var state = StateDay1(orientation: .east, x: 0, y: 0)
        try await processInstructions {
            try state.perform($0)
        }
        return abs(state.x) + abs(state.y)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var state = StateDay2(waypointX: 10, waypointY: -1, shipX: 0, shipY: 0)
        try await processInstructions {
            try state.perform($0)
        }
        return abs(state.shipX) + abs(state.shipY)
    }
    
    // MARK: - Utils
    
    private struct StateDay1 {
        var orientation: Orientation
        var x: Int
        var y: Int
        
        mutating func perform(_ instruction: Instruction) throws {
            switch (instruction.action, orientation) {
            case (.north, _), (.forward, .north):
                y -= instruction.value
                
            case (.south, _), (.forward, .south):
                y += instruction.value
                
            case (.east, _), (.forward, .east):
                x += instruction.value
                
            case (.west, _), (.forward, .west):
                x -= instruction.value
                
            case (.left, _):
                try orientation.rotateLeft(instruction.value)
                
            case (.right, _):
                try orientation.rotateRight(instruction.value)
            }
        }
    }
    
    private struct StateDay2 {
        var waypointX: Int
        var waypointY: Int
        
        var shipX: Int
        var shipY: Int
        
        mutating func perform(_ instruction: Instruction) throws {
            switch (instruction.action, instruction.value) {
            case (.north, _):
                waypointY -= instruction.value
            case (.south, _):
                waypointY += instruction.value
            case (.east, _):
                waypointX += instruction.value
            case (.west, _):
                waypointX -= instruction.value
            case (.forward, _):
                shipX += waypointX * instruction.value
                shipY += waypointY * instruction.value
            case (.left, 90), (.right, 270):
                let temp = waypointX
                waypointX = waypointY
                waypointY = -temp
            case (.left, 180), (.right, 180):
                waypointX *= -1
                waypointY *= -1
            case (.left, 270), (.right, 90):
                let temp = waypointX
                waypointX = -waypointY
                waypointY = temp
            default:
                throw InputError(message: "Invalid input")
            }
        }
    }
    
    private enum Orientation: Int {
        case north = 0
        case east = 1
        case south = 2
        case west = 3
        
        private mutating func rotate(_ offset: Int) {
            let newValue = (rawValue + offset + 4) % 4
            self = Orientation(rawValue: newValue) ?? self
        }
        
        private mutating func offsetForRotationValue(_ value: Int) throws -> Int {
            switch value {
            case 90:
                return 1
            case 180:
                return 2
            case 270:
                return 3
            default:
                throw InputError(message: "Invalid input")
            }
        }
        
        mutating func rotateLeft(_ value: Int) throws {
            try rotate(-offsetForRotationValue(value))
        }
        
        mutating func rotateRight(_ value: Int) throws {
            try rotate(offsetForRotationValue(value))
        }
    }
    
    private struct Instruction {
        var action: Action
        var value: Int
    }
    
    private enum Action: Character {
        case north = "N"
        case south = "S"
        case east = "E"
        case west = "W"
        case forward = "F"
        case right = "R"
        case left = "L"
    }
    
    private func processInstructions(_ handler: (Instruction) throws -> Void) async throws {
        try await getStreamedInput { line in
            guard line.count >= 2 else {
                throw InputError(message: "Invalid input")
            }
            
            let actionValue = line[line.startIndex]
            let valueString = String(line[line.index(after: line.startIndex)...])
            guard
                let action = Action(rawValue: actionValue),
                let value = Int(valueString)
            else {
                throw InputError(message: "Invalid input")
            }
            
            let instruction = Instruction(action: action, value: value)
            try handler(instruction)
        }
    }
}

import RegexBuilder
struct Assignment201507: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        return try getWire("a", for: instructions)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var instructions = try await getInstructions()
        
        let number = try getWire("a", for: instructions)
        update(&instructions, with: number, forWire: "b")
        
        return try getWire("a", for: instructions)
    }
    
    // MARK: - Utils
    
    private enum Value {
        case wire(String)
        case number(Int)
    }
    
    private enum Instruction {
        case unary(_ input: Value, _ outputWire: String, _ operator: (Int) -> Int)
        case binary(_ inputLeft: Value, _ inputRight: Value, _ outputWire: String, _ operator: (Int, Int) -> Int)
        
        var outputWire: String {
            switch self {
            case .unary(_, let outputWire, _),
                 .binary(_, _, let outputWire, _):
                return outputWire
            }
        }
        
        var number: Int? {
            switch self {
            case .unary(let input, _, let `operator`):
                guard case .number(let number) = input else {
                    return nil
                }
                return `operator`(number)
                
            case .binary(let inputLeft, let inputRight, _, let `operator`):
                guard
                    case .number(let numberLeft) = inputLeft,
                    case .number(let numberRight) = inputRight
                else {
                    return nil
                }
                return `operator`(numberLeft, numberRight)
            }
        }
        
        mutating func insert(number: Int, forWire wire: String) {
            switch self {
            case .unary(var input, let outputWire, let `operator`):
                if case .wire(let inputWire) = input, inputWire == wire {
                    input = .number(number)
                }
                self = .unary(input, outputWire, `operator`)
                
            case .binary(var inputLeft, var inputRight, let outputWire, let `operator`):
                if case .wire(let inputWire) = inputLeft, inputWire == wire {
                    inputLeft = .number(number)
                }
                if case .wire(let inputWire) = inputRight, inputWire == wire {
                    inputRight = .number(number)
                }
                self = .binary(inputLeft, inputRight, outputWire, `operator`)
            }
        }
    }
    
    private func getInstructions() async throws -> [Instruction] {
        return try await getInput()
            .split(separator: "\n")
            .map { try parseInstruction($0) }
    }
    
    private func parseValue(_ value: Substring) -> Value {
        if let number = Int(value) {
            return .number(number)
        }
        return .wire(String(value))
    }
    
    private func parseInstruction(_ value: Substring) throws -> Instruction {
        let parts = value.split(separator: " ")
        switch parts.count {
        case 3:
            return .unary(parseValue(parts[0]), String(parts[2]), +)
            
        case 4:
            if parts[0] == "NOT" {
                return .unary(parseValue(parts[1]), String(parts[3]), ~)
            }
            
        case 5:
            switch parts[1] {
            case "AND":
                return .binary(parseValue(parts[0]), parseValue(parts[2]), String(parts[4]), &)
            case "OR":
                return .binary(parseValue(parts[0]), parseValue(parts[2]), String(parts[4]), |)
            case "LSHIFT":
                return .binary(parseValue(parts[0]), parseValue(parts[2]), String(parts[4]), <<)
            case "RSHIFT":
                return .binary(parseValue(parts[0]), parseValue(parts[2]), String(parts[4]), >>)
            default:
                break
            }
            
        default:
            break
        }
        
        throw InputError(message: "Invalid instruction: \(value)")
    }
    
    private func update(_ instructions: inout [Instruction], with number: Int, forWire wire: String) {
        for i in 0..<instructions.count {
            instructions[i].insert(number: number, forWire: wire)
        }
    }
    
    private func getWire(_ wire: String, for instructions: [Instruction]) throws -> Int {
        var instructions = instructions
        
        repeat {
            guard let index = instructions.firstIndex(where: { $0.number != nil }) else {
                throw InputError(message: "Invalid input")
            }
            
            let instruction = instructions.remove(at: index)
            let wire = instruction.outputWire
            let number = instruction.number!
            
            if wire == "a" {
                return number
            }
            
            update(&instructions, with: number, forWire: wire)
            
        } while true
    }
}

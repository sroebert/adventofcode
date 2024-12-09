import RegexBuilder
struct Assignment201523: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        
        var memory = Memory()
        memory.performInstructions(instructions)
        return memory.b
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        
        var memory = Memory(a: 1)
        memory.performInstructions(instructions)
        return memory.b
    }
    
    // MARK: - Utils
    
    private struct Memory {
        var a = 0
        var b = 0
        
        mutating func performInstructions(_ instructions: [Instruction]) {
            var instructionIndex = 0
            
            let indices = instructions.indices
            while indices.contains(instructionIndex) {
                instructionIndex += instructions[instructionIndex](&self)
            }
        }
    }
    
    private typealias Instruction = (_ memory: inout Memory) -> Int
        
    private func parseRegister(_ value: Substring) throws -> WritableKeyPath<Memory, Int> {
        switch value {
        case "a": \.a
        case "b": \.b
        default: throw InputError(message: "Invalid input")
        }
    }
    
    private func parseJumpOffset(_ value: Substring?) throws -> Int {
        guard
            let value,
            let offset = Int(value.trimmingPrefix("+"))
        else {
            throw InputError(message: "Invalid input")
        }
        
        return offset
    }
    
    private func parseInstruction(_ line: String) throws -> Instruction {
        let parts = line.split(separator: " ", maxSplits: 1)
        guard parts.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        switch parts[0] {
        case "hlf":
            let register = try parseRegister(parts[1])
            return { memory in
                memory[keyPath: register] /= 2
                return 1
            }
            
        case "tpl":
            let register = try parseRegister(parts[1])
            return { memory in
                memory[keyPath: register] *= 3
                return 1
            }
            
        case "inc":
            let register = try parseRegister(parts[1])
            return { memory in
                memory[keyPath: register] += 1
                return 1
            }
            
        case "jmp":
            let offset = try parseJumpOffset(parts[1])
            return { _ in
                return offset
            }
            
        case "jie":
            let params = parts[1].split(separator: ", ")
            let register = try parseRegister(params[0])
            let offset = try parseJumpOffset(params[safe: 1])
            return { memory in
                guard (memory[keyPath: register] % 2) == 0 else {
                    return 1
                }
                return offset
            }
            
        case "jio":
            let params = parts[1].split(separator: ", ")
            let register = try parseRegister(params[0])
            let offset = try parseJumpOffset(params[safe: 1])
            return { memory in
                guard memory[keyPath: register] == 1 else {
                    return 1
                }
                return offset
            }
            
        default:
            throw InputError(message: "Invalid input")
        }
    }
    
    private func getInstructions() async throws -> [Instruction] {
        return try await mapInput { try parseInstruction($0) }
    }
}

struct Assignment202008: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let instructions = try await getInstructions()
        return run(instructions).finalState.accumulator
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var instructions = try await getInstructions()
        let failedRun = run(instructions)
        
        var stateList = failedRun.stateList
        while !stateList.isEmpty {
            let state = stateList.removeLast()
            guard instructions[state.instructionIndex].canSwap else {
                continue
            }
            
            instructions[state.instructionIndex].swap()
            let applicationRun = run(instructions, from: stateList)
            instructions[state.instructionIndex].swap()
            
            if applicationRun.finalState.instructionIndex >= instructions.count {
                return applicationRun.finalState.accumulator
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    // MARK: - Utils
    
    private enum Operation: String {
        case accumulate = "acc"
        case jump = "jmp"
        case noOperation = "nop"
        
        var canSwap: Bool {
            return self != .accumulate
        }
        
        mutating func swap() {
            switch self {
            case .accumulate:
                break
            case .jump:
                self = .noOperation
            case .noOperation:
                self = .jump
            }
        }
    }
    
    private struct Instruction {
        var operation: Operation
        var argument: Int
        
        var canSwap: Bool {
            return operation.canSwap
        }
        
        mutating func swap() {
            operation.swap()
        }
    }
    
    private struct State {
        var accumulator: Int = 0
        var instructionIndex: Int = 0
        
        func nextState(for instruction: Instruction) -> State {
            var newState = self
            switch instruction.operation {
            case .accumulate:
                newState.accumulator += instruction.argument
                newState.instructionIndex += 1
            case .jump:
                newState.instructionIndex += instruction.argument
            case .noOperation:
                newState.instructionIndex += 1
            }
            return newState
        }
    }
    
    private struct ApplicationRun {
        var finalState: State
        var stateList: [State] = []
    }
    
    private func getInstructions() async throws -> [Instruction] {
        let regex = /(?<operation>nop|acc|jmp) (?<direction>\+|-)(?<number>[\d]+)/
        return try await getInput()
            .split(separator: "\n")
            .compactMap { line in
                guard
                    let match = line.wholeMatch(of: regex),
                    let operation = Operation(rawValue: String(match.output.operation)),
                    let number = Int(match.output.number)
                else {
                    return nil
                }
                
                let argument = number * (match.output.direction == "-" ? -1 : 1)
                return Instruction(operation: operation, argument: argument)
            }
    }
    
    private func run(
        _ instructions: [Instruction],
        from fromStates: [State] = [State()]
    ) -> ApplicationRun {
        var state = fromStates.last!
        var stateList = fromStates
        
        var visitedIndices = Set<Int>(stateList.map { $0.instructionIndex })
        
        repeat {
            let nextState = state.nextState(for: instructions[state.instructionIndex])
            guard !visitedIndices.contains(nextState.instructionIndex) else {
                break
            }
            
            state = nextState
            
            visitedIndices.insert(state.instructionIndex)
            stateList.append(state)
            
        } while state.instructionIndex >= 0 && state.instructionIndex < instructions.count
        
        return ApplicationRun(
            finalState: state,
            stateList: stateList
        )
    }
}

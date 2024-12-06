struct Assignment202011: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var states = try await getStates()

        var didChange: Bool
        repeat {
            (states, didChange) = process(states) { x, y in
                var occupancyCount = 0
                for i in 0..<9 {
                    let checkX = x + (i % 3) - 1
                    let checkY = y + (i / 3) - 1

                    if (checkX != x || checkY != y) &&
                        checkX >= 0 && checkY >= 0 &&
                        checkX < states[0].count &&
                        checkY < states.count &&
                        states[checkY][checkX] == .occupied {

                        occupancyCount += 1
                        if states[y][x] == .empty || occupancyCount == 4 {
                            break
                        }
                    }
                }

                if states[y][x] == .empty && occupancyCount == 0 {
                    return .occupied
                }
                if states[y][x] == .occupied && occupancyCount >= 4 {
                    return .empty
                }
                return states[y][x]
            }

        } while didChange

        return countOccupied(for: states)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var states = try await getStates()
        
        var didChange: Bool
        repeat {
            (states, didChange) = process(states) { x, y in
                var occupancyCount = 0
                outerCheckLoop: for i in 0..<9 {
                    let stepX = (i % 3) - 1
                    let stepY = (i / 3) - 1
                    guard stepX != 0 || stepY != 0 else {
                        continue
                    }
                    
                    var checkX = x + stepX
                    var checkY = y + stepY
                    innerCheckLoop: while checkX >= 0 && checkY >= 0 &&
                                        checkX < states[0].count &&
                                        checkY < states.count
                    {
                        switch states[checkY][checkX] {
                        case .floor:
                            break
                        case .empty:
                            break innerCheckLoop
                        case .occupied:
                            occupancyCount += 1
                            if states[y][x] == .empty || occupancyCount == 5 {
                                break outerCheckLoop
                            }
                            break innerCheckLoop
                        }
                        
                        checkX += stepX
                        checkY += stepY
                    }
                }
                
                if states[y][x] == .empty && occupancyCount == 0 {
                    return .occupied
                }
                if states[y][x] == .occupied && occupancyCount >= 5 {
                    return .empty
                }
                return states[y][x]
            }
            
        } while didChange
        
        return countOccupied(for: states)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private enum State: CustomStringConvertible {
        case floor
        case empty
        case occupied
        
        init(_ character: Character) throws {
            switch character {
            case ".":
                self = .floor
            case "L":
                self = .empty
            default:
                throw InputError(message: "Invalid input")
            }
        }
        
        var description: String {
            switch self {
            case .floor:
                return "."
            case .empty:
                return "L"
            case .occupied:
                return "#"
            }
        }
    }
    
    private func getStates() async throws -> [[State]] {
        try await getInput()
            .split(separator: "\n")
            .map { line in
                try line.map { try State($0) }
            }
    }
    
    private func iterate(over states: [[State]], action: (Int, Int, State) -> Void) {
        let gridSize = states.count * states[0].count
        for i in 0..<gridSize {
            let x = i % states[0].count
            let y = i / states[0].count
            
            action(x, y, states[y][x])
        }
    }
    
    private func process(_ states: [[State]], determineState: (_ x: Int, _ y: Int) -> State) -> ([[State]], Bool) {
        var newStates = states
        var didChange = false
        
        iterate(over: states) { x, y, state in
            guard state != .floor else {
                return
            }
            
            let newState = determineState(x, y)
            guard newState != state else {
                return
            }
            
            didChange = true
            newStates[y][x] = newState
        }
        
        return (newStates, didChange)
    }
    
    private func countOccupied(for states: [[State]]) -> Int {
        var count = 0
        iterate(over: states) { _, _, state in
            if state == .occupied {
                count += 1
            }
        }
        return count
    }
}

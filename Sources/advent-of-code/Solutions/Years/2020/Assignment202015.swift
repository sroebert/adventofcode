struct Assignment202015: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var state = try await getState()
        while state.round != 2020 {
            state.nextRound()
        }
        return state.number
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var state = try await getState()
        while state.round != 30000000 {
            state.nextRound()
        }
        return state.number
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct State {
        var history: [Int: Int]
        var round: Int
        var number: Int
        
        mutating func nextRound() {
            let lastNumber = number
            
            if let previousRound = history[number] {
                number = round - previousRound
            } else {
                number = 0
            }
            
            history[lastNumber] = round
            round += 1
        }
    }
    
    private func getState() async throws -> State {
        let numbers = try await getInput()
            .split { $0 == "," || $0 == "\n" }
            .compactMap { Int($0) }
        
        var history: [Int: Int] = [:]
        for (index, number) in numbers[..<(numbers.count - 1)].enumerated() {
            history[number] = index + 1
        }
        
        return State(
            history: history,
            round: numbers.count,
            number: numbers[numbers.count - 1]
        )
    }
}

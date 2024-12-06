struct Assignment202023: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var state = try await getInitialState()
        for _ in 0..<100 {
            state.performMove()
        }
        return state.determineDay1Result()
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var state = try await getInitialState(maxCount: 1_000_000)
        for _ in 0..<10_000_000 {
            state.performMove()
        }

        let nextCup = state.cupMapping[0]
        let nextNextCup = state.cupMapping[nextCup - 1]
        return nextCup * nextNextCup
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct State {
        var currentCup: Int
        var cupMapping: [Int]
        
        mutating func determineDay1Result() -> String {
            var cup = currentCup
            while cup != 1 {
                cup = cupMapping[cup - 1]
            }
            cup = cupMapping[cup - 1]
            
            var result = ""
            while cup != 1 {
                result += String(cup)
                cup = cupMapping[cup - 1]
            }
            
            return result
        }
        
        mutating func performMove() {
            // Remove 3 cups
            let removedCup1 = cupMapping[currentCup - 1]
            let removedCup2 = cupMapping[removedCup1 - 1]
            let removedCup3 = cupMapping[removedCup2 - 1]
            
            // Link the next cup, basically removing the 3 from the linked list
            cupMapping[currentCup - 1] = cupMapping[removedCup3 - 1]
            
            // Find destination cup
            var destinationCup = currentCup
            repeat {
                destinationCup = ((destinationCup + cupMapping.count - 2) % cupMapping.count) + 1
            } while destinationCup == removedCup1 || destinationCup == removedCup2 || destinationCup == removedCup3
            
            // Insert removed cups
            cupMapping[removedCup3 - 1] = cupMapping[destinationCup - 1]
            cupMapping[destinationCup - 1] = removedCup1
            
            // Make next cup the current
            currentCup = cupMapping[currentCup - 1]
        }
    }
    
    private func getInitialState(maxCount: Int? = nil) async throws -> State {
        let cups = try await getInput().compactMap { Int(String($0)) }
        let firstCup = cups[0]
        
        var cupMapping: [Int] = Array(repeating: 0, count: cups.count)
        
        var currentCup = firstCup
        for cup in cups[1...] {
            cupMapping[currentCup - 1] = cup
            currentCup = cup
        }
        
        if let maxCount = maxCount, cupMapping.count < maxCount {
            cupMapping[currentCup - 1] = cupMapping.count + 1
            cupMapping.append(contentsOf: (cupMapping.count + 2)...maxCount)
            cupMapping.append(firstCup)
        } else {
            cupMapping[currentCup - 1] = firstCup
        }
        
        return State(
            currentCup: firstCup,
            cupMapping: cupMapping
        )
    }
}

struct Assignment201513: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let scores = try await getSeatingScores()
        return determineBestSeating(forScores: scores)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let scores = try await getSeatingScores(includeSelf: true)
        return determineBestSeating(forScores: scores)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func getSeatingScores(includeSelf: Bool = false) async throws -> [[Int]] {
        var mapping: [String: Int] = [:]
        var scoreMappings: [[Int: Int]] = []
        
        let getIndex = { (name: String) -> Int in
            if let index = mapping[name] {
                return index
            }
            
            let index = mapping.count
            mapping[name] = index
            scoreMappings.append([:])
            return index
        }
        
        let regex = /(?<subject>\w+) would (?<loseOrGain>lose|gain) (?<score>\d+) happiness units by sitting next to (?<target>\w+)\./
        try await getStreamedInput { line in
            guard let match = line.wholeMatch(of: regex) else {
                throw InputError(message: "Invalid input")
            }
            
            let index1 = getIndex(String(match.output.subject))
            let index2 = getIndex(String(match.output.target))
            let score = (Int(match.output.score) ?? 0) * (match.output.loseOrGain == "lose" ? -1 : 1)
            scoreMappings[index1][index2] = score
        }
        
        var scores = Array(repeating: Array(repeating: 0, count: mapping.count), count: mapping.count)
        for (index1, scoreMapping) in scoreMappings.enumerated() {
            for (index2, score) in scoreMapping {
                scores[index1][index2] = score
            }
            
            if includeSelf {
                scores[index1].append(0)
            }
        }
        
        if includeSelf {
            scores.append(Array(repeating: 0, count: mapping.count + 1))
        }
        
        return scores
    }
    
    private func determineBestSeating(forScores scores: [[Int]]) -> Int {
        var bestScore: Int = Int.min
        for order in (0..<scores.count).permutations() {
            var score =
                scores[order[0]][order[order.count - 1]] +
                scores[order[order.count - 1]][order[0]]
            
            var previousPerson = order[0]
            for person in order[1...] {
                score +=
                    scores[previousPerson][person] +
                    scores[person][previousPerson]
                
                previousPerson = person
            }
            
            if score > bestScore {
                bestScore = score
            }
        }
        return bestScore
    }
}

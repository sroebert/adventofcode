struct Assignment201514: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getReindeer()
            .map { $0.distance(afterSeconds: 2503) }
            .sorted()
            .last ?? 0
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let reindeer = try await getReindeer()
        
        var scores: [Int] = Array(repeating: 0, count: reindeer.count)
        for seconds in 1...2503 {
            let distances = reindeer.map { $0.distance(afterSeconds: seconds) }
            
            var furthestDistance = 0
            for distance in distances {
                if distance > furthestDistance {
                    furthestDistance = distance
                }
            }
            
            for (index, distance) in distances.enumerated() {
                if distance == furthestDistance {
                    scores[index] += 1
                }
            }
        }
        
        return scores.sorted().last ?? 0
    }
    
    // MARK: - Utils
    
    private struct Reindeer {
        var speed: Int
        var flyTime: Int
        var restTime: Int
        
        func distance(afterSeconds seconds: Int) -> Int {
            let loopTime = flyTime + restTime
            let loops = seconds / loopTime
            let lastSeconds = seconds % loopTime
            return loops * flyTime * speed + min(flyTime, lastSeconds) * speed
        }
    }
    
    private func getReindeer() async throws -> [Reindeer] {
        let regex = /\w+ can fly (?<speed>\d+) km\/s for (?<flyTime>\d+) seconds, but then must rest for (?<restTime>\d+) seconds\./
        return try await getInput()
            .split(separator: "\n")
            .map { line in
                guard let match = line.wholeMatch(of: regex) else {
                    throw InputError(message: "Invalid input")
                }
                return Reindeer(
                    speed: Int(match.output.speed) ?? 0,
                    flyTime: Int(match.output.flyTime) ?? 0,
                    restTime: Int(match.output.restTime) ?? 0
                )
            }
    }
}

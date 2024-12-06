struct Assignment202403: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getInput().multiplyCount
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var current = try await Substring(getInput())
        
        var isEnabled = true
        var count = 0
        
        while true {
            guard let range = current.range(of: isEnabled ? Self.disableInstruction : Self.enableInstruction) else {
                count += isEnabled ? current.multiplyCount : 0
                return count
            }
            
            if isEnabled {
                count += current[..<range.lowerBound].multiplyCount
            }
            isEnabled.toggle()
            current = current[range.upperBound...]
        }
    }
    
    // MARK: - Utils
    
    private static let enableInstruction = "do()"
    private static let disableInstruction = "don't()"
}

private extension StringProtocol where SubSequence == Substring {
    var multiplyCount: Int {
        let mulRegex = /mul\((?<a>\d+),(?<b>\d+)\)/
        return matches(of: mulRegex).map {
            (Int($0.output.a) ?? 0) * (Int($0.output.b) ?? 0)
        }.reduce(0, +)
    }
}

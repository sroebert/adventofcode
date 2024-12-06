struct Assignment201508: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var count = 0
        try await getStreamedInput { line in
            count += 2
            
            var line = line[line.index(after: line.startIndex)..<line.index(before: line.endIndex)]
            while let index = line.firstIndex(of: "\\"),
                  index < line.index(before: line.endIndex) {
                
                switch line[line.index(after: index)] {
                case "\\", "\"":
                    count += 1
                    line = line[line.index(index, offsetBy: 2)...]
                    
                case "x":
                    count += 3
                    line = line[line.index(index, offsetBy: 4)...]
                    
                default:
                    line = line[line.index(after: index)...]
                }
            }
        }
        return count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var count = 0
        try await getStreamedInput { line in
            count += 4
            
            var line = line[line.index(after: line.startIndex)..<line.index(before: line.endIndex)]
            while let index = line.firstIndex(of: "\\"),
                  index < line.index(before: line.endIndex) {
                
                switch line[line.index(after: index)] {
                case "\\", "\"":
                    count += 2
                    line = line[line.index(index, offsetBy: 2)...]
                    
                case "x":
                    count += 1
                    line = line[line.index(index, offsetBy: 4)...]
                    
                default:
                    line = line[line.index(after: index)...]
                }
            }
        }
        return count
    }
}

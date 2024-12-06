struct Assignment201505: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var nice = 0
        try await getStreamedInput { string in
            let otherString = string.dropFirst() + " "
            
            var vowelCount = 0
            var hasTwoInARow = false
            for (c1, c2) in zip(string, otherString) {
                switch (c1, c2) {
                case ("a", "b"), ("c", "d"), ("p", "q"), ("x", "y"):
                    return
                default:
                    break
                }
                
                if c1 == c2 {
                    hasTwoInARow = true
                }
                
                if "aeiou".contains(c1) {
                    vowelCount += 1
                }
            }
            
            if vowelCount >= 3 && hasTwoInARow {
                nice += 1
            }
        }
        return nice
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var nice = 0
        
        let rule1 = /([a-z]{2}).*\1/
        let rule2 = /([a-z])[a-z]\1/
        
        try await getStreamedInput { string in
            if string.firstMatch(of: rule1) != nil && string.firstMatch(of: rule2) != nil {
                nice += 1
            }
        }
        
        return nice
    }
}

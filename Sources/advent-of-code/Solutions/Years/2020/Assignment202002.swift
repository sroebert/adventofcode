struct Assignment202002: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getEntries().count { $0.isValidPart1 }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await getEntries().count { $0.isValidPart2 }
    }
    
    // MARK: - Utils
    
    private struct PasswordEnty {
        var password: String
        
        var policyLetter: Character
        var policyNumber1: Int
        var policyNumber2: Int
        
        var isValidPart1: Bool {
            let letterCount = password.count { $0 == policyLetter }
            return letterCount >= policyNumber1 && letterCount <= policyNumber2
        }
        
        var isValidPart2: Bool {
            return (self[safe: policyNumber1] == policyLetter) !=
                (self[safe: policyNumber2] == policyLetter)
        }
        
        subscript(safe index: Int) -> Character? {
            guard index > 0 && password.count >= index else {
                return nil
            }
            
            let index = password.index(password.startIndex, offsetBy: index - 1)
            return password[index]
        }
        
        init?<T: Sequence>(string: T) where T.Element == Character {
            let parts = string.split(separator: " ")
            guard parts.count == 3 else {
                return nil
            }
            
            let policyNumbers = parts[0].split(separator: "-")
            guard
                policyNumbers.count == 2,
                let policyNumber1 = Int(String(policyNumbers[0])),
                let policyNumber2 = Int(String(policyNumbers[1]))
            else {
                return nil
            }
            
            guard let policyLetter = parts[1].first,
                parts[1].count == 2 &&
                parts[1].last == ":"
            else {
                return nil
            }
            
            password = String(parts[2])
            
            self.policyLetter = policyLetter
            self.policyNumber1 = policyNumber1
            self.policyNumber2 = policyNumber2
        }
    }
    
    private func getEntries() async throws -> [PasswordEnty] {
        let lines = try await getInput().split(separator: "\n")
        let entries = lines.compactMap { PasswordEnty(string: $0) }
        
        guard lines.count == entries.count else {
            throw InputError(message: "Invalid input")
        }
        
        return entries
    }
}

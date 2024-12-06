struct Assignment201511: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var password = try await getPassword()
        repeat {
            increasePassword(&password)
        } while !isValidPassword(password)
        return passwordToString(password)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var password = try await getPassword()
        repeat {
            increasePassword(&password)
        } while !isValidPassword(password)
        repeat {
            increasePassword(&password)
        } while !isValidPassword(password)
        return passwordToString(password)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private static let firstPasswordCharacter: Character = "a"
    private static let lastPasswordCharacter: Character = "z"
    private static let passwordMaxValue: UInt8 = lastPasswordCharacter.asciiValue! - firstPasswordCharacter.asciiValue!
    
    private static let invalidLetters = "iol".map { $0.asciiValue! }
    
    private func hasIncreasingStraight(_ password: [UInt8]) -> Bool {
        for index in (0..<password.count - 2).lazy.reversed() {
            if password[index + 1] == password[index] + 1 &&
                password[index + 2] == password[index] + 2
            {
                return true
            }
        }
        return false
    }
    
    private func containsDistinctPairs(_ password: [UInt8]) -> Bool {
        var firstPair: UInt8? = nil
        for index in (0..<password.count - 1).lazy.reversed() {
            if password[index] == password[index + 1] {
                if let firstPair = firstPair {
                    if password[index] != firstPair {
                        return true
                    }
                } else {
                    firstPair = password[index]
                }
            }
        }
        return false
    }

    private func isValidPassword(_ password: [UInt8]) -> Bool {
        return hasIncreasingStraight(password) && containsDistinctPairs(password)
    }

    private func increasePassword(_ password: inout [UInt8]) {
        var index = password.count - 1
        
        repeat {
            password[index] += 1
        } while Self.invalidLetters.contains(password[index])
        
        while index > 0 && password[index] > Self.passwordMaxValue {
            password[index] = 0
            
            repeat {
                password[index - 1] += 1
            } while Self.invalidLetters.contains(password[index - 1])
            
            index -= 1
        }
    }
    
    private func getPassword() async throws -> [UInt8] {
        let input = try await getInput().split(separator: "\n")[0]
        return input.map { $0.asciiValue! - Self.firstPasswordCharacter.asciiValue! }
    }
    
    private func passwordToString(_ password: [UInt8]) -> String {
        return String(password.map { Character(UnicodeScalar($0 + Self.firstPasswordCharacter.asciiValue!)) })
    }
}

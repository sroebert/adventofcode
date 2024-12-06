struct Assignment202025: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let (cardPublicKey, doorPublicKey) = try await getPublicKeys()
        return determineEncryptionKey(cardPublicKey: cardPublicKey, doorPublicKey: doorPublicKey)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        return "N/A"
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private let subjectNumber = 7
    private let transformDivider = 20201227
    
    private func getPublicKeys() async throws -> (Int, Int) {
        let input = try await getInput().split(separator: "\n").compactMap { Int($0) }
        guard input.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        return (input[0], input[1])
    }
    
    private func transform(_ number: Int, loopSize: Int) -> Int {
        var value = 1
        for _ in 0..<loopSize {
            value *= number
            value %= transformDivider
        }
        return value
    }
    
    private func determineEncryptionKey(cardPublicKey: Int, doorPublicKey: Int) -> Int {
        var cardValue = cardPublicKey
        var doorValue = doorPublicKey
        
        var loopSize = 0
        while cardValue != 1 && doorValue != 1 {
            loopSize += 1
            
            while (cardValue % subjectNumber) != 0 {
                cardValue += transformDivider
            }
            cardValue /= subjectNumber
            
            while (doorValue % subjectNumber) != 0 {
                doorValue += transformDivider
            }
            doorValue /= subjectNumber
        }
        
        if cardValue == 1 {
            return transform(doorPublicKey, loopSize: loopSize)
        }
        return transform(cardPublicKey, loopSize: loopSize)
    }
}

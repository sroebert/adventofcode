struct Assignment201520: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let input = try await getInput().trimming(while: \.isWhitespace)
        guard let minimumPresents = Int(input) else {
            throw InputError(message: "Invalid input")
        }
        
        let offset = minimumPresents / 10
        var houses = Array(repeating: 1, count: offset)
        
        for elve in 2...offset {
            var houseId = elve
            while houseId < offset {
                houses[houseId - 1] += elve
                houseId += elve
            }
        }
        
        guard let index = houses.firstIndex(where: { $0 >= offset }) else  {
            throw InputError(message: "Invalid input")
        }
        
        return index + 1
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let input = try await getInput().trimming(while: \.isWhitespace)
        guard let minimumPresents = Int(input) else {
            throw InputError(message: "Invalid input")
        }
        
        let offset = minimumPresents / 11
        var houses = Array(repeating: 0, count: offset)
        
        for elve in 1...offset {
            var houseId = elve
            let maxHouseId = min(offset, houseId + elve * 50)
            while houseId < maxHouseId {
                houses[houseId - 1] += elve
                houseId += elve
            }
        }
        
        guard let index = houses.firstIndex(where: { $0 >= offset }) else  {
            throw InputError(message: "Invalid input")
        }
        
        return index + 1
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
}

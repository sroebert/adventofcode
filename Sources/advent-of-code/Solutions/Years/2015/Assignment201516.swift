struct Assignment201516: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let detection: Detection = [
            .children: 3...3,
            .cats: 7...7,
            .samoyeds: 2...2,
            .pomeranians: 3...3,
            .akitas: 0...0,
            .vizslas: 0...0,
            .goldfish: 5...5,
            .trees: 3...3,
            .cars: 2...2,
            .perfumes: 1...1
        ]
        return try await findAunt(for: detection)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let detection: Detection = [
            .children: 3...3,
            .cats: 8...,
            .samoyeds: 2...2,
            .pomeranians: ...2,
            .akitas: 0...0,
            .vizslas: 0...0,
            .goldfish: ...4,
            .trees: 4...,
            .cars: 2...2,
            .perfumes: 1...1
        ]
        return try await findAunt(for: detection)
    }
    
    // MARK: - Utils
    
    private enum Compound: String, CaseIterable {
        case children
        case cats
        case samoyeds
        case pomeranians
        case akitas
        case vizslas
        case goldfish
        case trees
        case cars
        case perfumes
    }
    
    private typealias Detection = Dictionary<Compound, any RangeExpression<Int>>
    
    private func getAunts() async throws -> [Dictionary<Compound, Int>] {
        let compoundRegex = /(?<compound>\w+): (?<compoundValue>\d+)/
        
        return try await mapInput { line in
            var knownCompounds: Dictionary<Compound, Int> = [:]
            
            for match in line.matches(of: compoundRegex) {
                if let compound = Compound(rawValue: String(match.output.compound)) {
                    knownCompounds[compound] = Int(match.output.compoundValue)
                }
            }
            
            return knownCompounds
        }
    }
    
    private func findAunt(for detection: Detection) async throws -> Int {
        let aunts = try await getAunts()
        
        auntLoop: for (index, aunt) in aunts.enumerated() {
            for (detectionCompound, detectionRange) in detection {
                if let value = aunt[detectionCompound], !detectionRange.contains(value) {
                    continue auntLoop
                }
            }
            
            return index + 1
        }
        
        throw InputError(message: "Invalid input")
    }
}

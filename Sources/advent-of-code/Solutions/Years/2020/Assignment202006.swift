struct Assignment202006: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getEntries().reduce(0) { $0 + $1.yesAnswers.count }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await getEntries().reduce(0) { totalCount, entry in
            totalCount + entry.yesAnswers.count { $0.value == entry.personCount }
        }
    }
    
    // MARK: - Utils
    
    private struct Entry {
        var yesAnswers: [Character: Int]
        var personCount: Int
    }
    
    private func getEntries() async throws -> [Entry] {
        return try await getInput()
            .split(separator: "\n\n")
            .map { groupLines in
                let peopleLines = groupLines.split(separator: "\n")
                let yesAnswers = peopleLines.reduce([Character: Int]()) { dictionary, line in
                    var dictionary = dictionary
                    line.forEach { character in
                        if let count = dictionary[character] {
                            dictionary[character] = count + 1
                        } else {
                            dictionary[character] = 1
                        }
                    }
                    return dictionary
                }
                return Entry(yesAnswers: yesAnswers, personCount: peopleLines.count)
            }
    }
}

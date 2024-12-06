struct Assignment202016: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let data = try await getTicketData()
        return data.nearbyTickets
            .flatMap { $0.values }
            .filter { value in !data.rules.contains { $0.contains(value) } }
            .reduce(0, +)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var data = try await getTicketData()
        data.nearbyTickets.removeAll { ticket in
            ticket.values.contains { value in
                !data.rules.contains { $0.contains(value) }
            }
        }
        
        var allTickets = data.nearbyTickets
        allTickets.append(data.yourTicket)
        
        var fieldIndices = Array(0..<data.rules.count)
        
        var mappedRules: [Int:Rule] = [:]
        outerLoop: while !data.rules.isEmpty {
            fieldLoop: for (arrayIndex, fieldIndex) in fieldIndices.enumerated() {
                
                var validRuleIndex: Int? = nil
                for (ruleIndex, rule) in data.rules.enumerated() {
                    if !allTickets.contains(where: { !rule.contains($0.values[fieldIndex]) }) {
                        if validRuleIndex != nil {
                            continue fieldLoop
                        }
                        validRuleIndex = ruleIndex
                    }
                }
                
                if let ruleIndex = validRuleIndex {
                    let rule = data.rules.remove(at: ruleIndex)
                    mappedRules[fieldIndex] = rule
                    fieldIndices.remove(at: arrayIndex)
                    
                    continue outerLoop
                }
            }
        }
        
        return mappedRules
            .filter { $1.fieldName.starts(with: "departure") }
            .reduce(1) { $0 * data.yourTicket.values[$1.key] }
    }
    
    // MARK: - Utils
    
    private struct Rule {
        var fieldName: String
        var valueRange1: ClosedRange<Int>
        var valueRange2: ClosedRange<Int>
        
        func contains(_ value: Int) -> Bool {
            return valueRange1.contains(value) || valueRange2.contains(value)
        }
    }
    
    private struct Ticket {
        var values: [Int]
    }
    
    private struct TicketData {
        var rules: [Rule]
        var yourTicket: Ticket
        var nearbyTickets: [Ticket]
    }
    
    private func parseRules(from string: Substring) -> [Rule] {
        let regex = /(?<fieldName>.+): (?<from1>\d+)-(?<to1>\d+) or (?<from2>\d+)-(?<to2>\d+)/
        return string.split(separator: "\n").compactMap { line in
            guard let match = line.wholeMatch(of: regex) else {
                return nil
            }
            
            return Rule(
                fieldName: String(match.output.fieldName),
                valueRange1: (Int(match.output.from1) ?? 0)...(Int(match.output.to1) ?? 0),
                valueRange2: (Int(match.output.from2) ?? 0)...(Int(match.output.to2) ?? 0)
            )
        }
    }
    
    private func parseTicketSection(from string: Substring) throws -> [Ticket] {
        let parts = string.split(separator: "\n")
        guard parts.count > 1 else {
            throw InputError(message: "Invalid input")
        }
        return parts[1...].map { parseTicket(from: String($0)) }
    }
    
    private func parseTicket(from string: String) -> Ticket {
        return Ticket(
            values: string
                .split(separator: ",")
                .compactMap { Int($0) }
        )
    }
    
    private func getTicketData() async throws -> TicketData {
        let parts = try await getInput().split(separator: "\n\n")
        guard parts.count == 3 else {
            throw InputError(message: "Invalid input")
        }
        
        let rules = parseRules(from: parts[0])
        let yourTicket = try parseTicketSection(from: parts[1])[0]
        let nearbyTickets = try parseTicketSection(from: parts[2])
        
        return TicketData(
            rules: rules,
            yourTicket: yourTicket,
            nearbyTickets: nearbyTickets
        )
    }
}

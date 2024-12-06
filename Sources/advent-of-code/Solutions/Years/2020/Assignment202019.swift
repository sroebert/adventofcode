struct Assignment202019: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let data = try await getData()
        guard let zeroRule = data.rules[0] else {
            throw InputError(message: "Invalid input")
        }
        
        let regex = try zeroRule.toRegex(with: data.rules)
        return data.messages.count { $0.firstMatch(of: regex) != nil }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let data = try await getData()
        guard let zeroRule = data.rules[0] else {
            throw InputError(message: "Invalid input")
        }
        
        var maxMessageLength = 0
        data.messages.forEach {
            if $0.count > maxMessageLength {
                maxMessageLength = $0.count
            }
        }
        
        let regex = try zeroRule.toDuplicatingRegex(with: data.rules, maxLength: maxMessageLength)
        return data.messages.count { $0.firstMatch(of: regex) != nil }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private indirect enum Rule {
        case character(Character)
        case index(Int)
        case and([Rule])
        case or([Rule])
        
        private var minLength: Int {
            get throws {
                switch self {
                case .character:
                    return 1
                case .index:
                    throw InputError(message: "Need to expand first")
                case .and(let rules):
                    return try rules.reduce(0) { try $0 + $1.minLength }
                case .or(let rules):
                    var minLength = Int.max
                    try rules.forEach {
                        let ruleLength = try $0.minLength
                        if ruleLength < minLength {
                            minLength = ruleLength
                        }
                    }
                    return minLength
                }
            }
        }
        
        private mutating func expand(with rules: [Int: Rule]) {
            switch self {
            case .character:
                break
            
            case .index(let index):
                guard var rule = rules[index] else {
                    return
                }
                rule.expand(with: rules)
                self = rule
                
            case .and(var andRules):
                for i in 0..<andRules.count {
                    andRules[i].expand(with: rules)
                }
                self = .and(andRules)
                
            case .or(var orRules):
                for i in 0..<orRules.count {
                    orRules[i].expand(with: rules)
                }
                self = .or(orRules)
            }
        }
        
        private func toRegexPattern() throws -> String {
            switch self {
            case .character(let character):
                return String(character)
                
            case .index:
                throw InputError(message: "Needs to be expanded first")
                
            case .and(let rules):
                return try rules.map { try $0.toRegexPattern() }.joined()
                
            case .or(let rules):
                let orPattern = try rules.map { try $0.toRegexPattern() }.joined(separator: "|")
                return "(\(orPattern))"
            }
        }
        
        func toRegex(with rules: [Int: Rule]) throws -> Regex<AnyRegexOutput> {
            var expandedSelf = self
            expandedSelf.expand(with: rules)
            
            let pattern = try expandedSelf.toRegexPattern()
            
            do {
                return try Regex( "^\(pattern)$")
            } catch {
                throw InputError(message: "Invalid input")
            }
        }
        
        func toDuplicatingRegex(with rules: [Int: Rule], maxLength: Int) throws -> Regex<AnyRegexOutput> {
            var expandedSelf = self
            expandedSelf.expand(with: rules)
            
            guard
                case .and(let andRules) = expandedSelf,
                andRules.count == 2,
                case .and(let leftAndRules) = andRules[0],
                leftAndRules.count == 1,
                case .and(let rightAndRules) = andRules[1],
                rightAndRules.count == 2
            else {
                throw InputError(message: "Invalid input")
            }
            
            let leftLength = try leftAndRules[0].minLength
            let rightLength = try rightAndRules[0].minLength + rightAndRules[1].minLength
            let rightMaxCount = ((maxLength - leftLength) / rightLength) + 1
            
            let leftPattern = try leftAndRules[0].toRegexPattern()
            let rightPattern1 = try rightAndRules[0].toRegexPattern()
            let rightPattern2 = try rightAndRules[1].toRegexPattern()
            
            let rightPattern = (1...rightMaxCount).map { count in
                "\(rightPattern1){\(count)}\(rightPattern2){\(count)}"
            }.joined(separator: "|")
            
            let pattern = "\(leftPattern)+(\(rightPattern))"
            
            do {
                return try Regex("^\(pattern)$")
            } catch {
                throw InputError(message: "Invalid input")
            }
        }
    }
    
    private struct InputData {
        var rules: [Int: Rule]
        var messages: [String]
    }
    
    private func getAndRule<T: StringProtocol>(for string: T) throws -> Rule {
        return try .and(
            string.split(separator: " ").compactMap { character in
                guard character != "" else {
                    return nil
                }
                
                guard let index = Int(character) else {
                    throw InputError(message: "Invalid input")
                }
                
                return .index(index)
            }
        )
    }
    
    private func getRules(from strings: [String]) throws -> [Int: Rule] {
        var rules: [Int: Rule] = [:]
        
        try strings.forEach { string in
            guard
                let numberEndIndex = string.firstIndex(of: ":"),
                let index = Int(string[..<numberEndIndex])
            else {
                throw InputError(message: "Invalid input")
            }
            
            let ruleOffset = string.index(numberEndIndex, offsetBy: 2)
            
            if string[ruleOffset] == "\"" {
                rules[index] = .character(string[string.index(after: ruleOffset)])
            } else if let orIndex = string.firstIndex(of: "|") {
                rules[index] = try .or([
                    getAndRule(for: string[ruleOffset..<orIndex]),
                    getAndRule(for: string[string.index(after: orIndex)...]),
                ])
            } else {
                rules[index] = try getAndRule(for: string[ruleOffset...])
            }
        }
        
        return rules
    }
    
    private func getData() async throws -> InputData {
        let data = try await getInput().components(separatedBy: "\n\n")
        guard data.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        return try .init(
            rules: getRules(from: data[0].components(separatedBy: "\n")),
            messages: data[1].components(separatedBy: "\n")
        )
    }
}

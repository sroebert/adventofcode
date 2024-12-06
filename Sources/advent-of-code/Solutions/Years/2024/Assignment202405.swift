import RegexBuilder
import Algorithms
import Collections

struct Assignment202405: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let (rules, updates) = try await getRulesAndUpdates()
        
        return updates.map { update in
            update.isValidUpdate(forRules: rules) ? update[update.count / 2] : 0
        }.reduce(0, +)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let (rules, updates) = try await getRulesAndUpdates()
        
        return updates.map { update in
            guard let fixed = update.fixUpdateIfNeeded(forRules: rules) else {
                return 0
            }
            return fixed[update.count / 2]
        }.reduce(0, +)
    }
    
    // MARK: - Utils
    
    private func getRulesAndUpdates() async throws -> (rules: Dictionary<Int, Set<Int>>, updates: [[Int]]) {
        let parts = try await getInput().split(separator: "\n\n")
        guard parts.count == 2 else {
            throw InputError(message: "Too many input parts")
        }
        
        let ruleBefore = Reference(Int.self)
        let ruleAfter = Reference(Int.self)
        let rulesRegex = Regex {
            TryCapture(as: ruleBefore) {
                OneOrMore(.digit)
            } transform: {
                Int($0)!
            }
            "|"
            TryCapture(as: ruleAfter) {
                OneOrMore(.digit)
            } transform: {
                Int($0)!
            }
        }
        
        let rules: Dictionary<Int, Set<Int>> = parts[0]
            .matches(of: rulesRegex)
            .map { ($0[ruleBefore], $0[ruleAfter]) }
            .reduce([:]) { dictionary, pair in
                var dictionary = dictionary
                dictionary[pair.0] = dictionary[pair.0, default: Set()].union([pair.1])
                return dictionary
            }
        
        let updates = parts[1].split(separator: "\n").map {
            $0.split(separator: ",").compactMap { Int($0) }
        }
                               
        return (rules, updates)
    }
}

private extension [Int] {
    func isValidUpdate(forRules rules: Dictionary<Int, Set<Int>>) -> Bool {
        var pagesToProcess = self
        var printed = Set<Int>()
        
        while !pagesToProcess.isEmpty {
            let page = pagesToProcess.removeFirst()
            if let pagesAfter = rules[page], !pagesAfter.isDisjoint(with: printed) {
                return false
            }
            printed.insert(page)
        }
        
        return true
    }
    
    func fixUpdateIfNeeded(forRules rules: Dictionary<Int, Set<Int>>) -> Self? {
        var didFix = false
        var fixedUpdate = OrderedSet<Int>()
        
        var pagesToProcess = self
        
        while !pagesToProcess.isEmpty {
            let page = pagesToProcess.removeFirst()
            
            let pagesAfter = rules[page] ?? Set()
            fixedUpdate.append(page)
            fixedUpdate.forEach {
                if pagesAfter.contains($0) {
                    didFix = true
                    fixedUpdate.remove($0)
                    fixedUpdate.append($0)
                }
            }
        }
        
        return didFix ? fixedUpdate.elements : nil
    }
}

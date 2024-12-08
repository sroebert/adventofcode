import Algorithms
import Foundation

struct Assignment201519: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let (replacements, input) = try await getData()
        
        var molecules = Set<String>()
        
        replacements.forEach { search, replacementArray in
            input.ranges(of: search).forEach { range in
                replacementArray.forEach { replacement in
                    var molecule = input
                    molecule.replaceSubrange(range, with: replacement)
                    molecules.insert(molecule)
                }
            }
        }
        
        return molecules.count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let (replacements, input) = try await getData()
        
        var replacementsToEmpty = replacements
        if let eReplacements = replacementsToEmpty["e"] {
            replacementsToEmpty.removeValue(forKey: "e")
            replacementsToEmpty[""] = eReplacements
        }
        
        var stack = [(count: 0, input: input)]
        while !stack.isEmpty {
            let (count, input) = stack.removeLast()
            
            guard !input.isEmpty else {
                return count
            }
            
            let insertionIndex = stack.binarySearch { $0.count < count + 1 }
            
            replacementsToEmpty.forEach { search, replacementArray in
                replacementArray.forEach { replacement in
                    input.ranges(of: replacement).forEach { range in
                        var reducedInput = input
                        reducedInput.replaceSubrange(range, with: search)
                        
                        stack.insert((count + 1, reducedInput), at: insertionIndex)
                    }
                }
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func getData() async throws -> (replacements: [String: [String]], input: String) {
        let parts = try await getInput().split(separator: "\n\n")
        guard parts.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        var replacements: [String: [String]] = [:]
        try parts[0].split(separator: "\n").forEach { line in
            let lineParts = line.split(separator: " => ")
            guard lineParts.count == 2 else {
                throw InputError(message: "Invalid input")
            }
            
            let search = String(lineParts[0])
            
            var replacementArray = replacements[search, default: []]
            replacementArray.append(String(lineParts[1]))
            replacements[search] = replacementArray
        }
        
        return (replacements, String(parts[1].trimming(while: \.isWhitespace)))
    }
}

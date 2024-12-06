import Foundation

struct Assignment201512: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await countInputJSON()
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await countInputJSON(filter: "red")
    }
    
    // MARK: - Utils
    
    private func getJSON() async throws -> Any {
        do {
            return try await JSONSerialization.jsonObject(with: getInputData(), options: [])
        } catch {
            throw InputError(message: "Invalid input")
        }
    }
    
    private func countInputJSON(filter: String? = nil) async throws -> Int {
        var count = 0
        var stack = try await [getJSON()]
        
        while !stack.isEmpty {
            let object = stack.removeFirst()
            
            if let array = object as? [Any] {
                stack.append(contentsOf: array)
            } else if let dictionary = object as? [String: Any] {
                let values = dictionary.values
                if filter == nil || !values.contains(where: { $0 as? String == filter }) {
                    stack.append(contentsOf: values)
                }
            } else if let number = object as? NSNumber {
                count += number.intValue
            }
        }
        
        return count
    }
}

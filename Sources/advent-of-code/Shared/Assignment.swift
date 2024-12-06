import Foundation

protocol Assignment: Sendable {
    func getIdentifier() -> (day: Int, year: Int)
    
    func solvePart1() async throws -> String
    func solvePart2() async throws -> String
}

extension Assignment {
    func getIdentifier() -> (day: Int, year: Int) {
        let identifierRegex = /Assignment(?<year>[0-9]{4})(?<day>[0-9]{2})/
        
        let assignmentName = "\(Mirror(reflecting: self).subjectType)"
        guard let match = try? identifierRegex.wholeMatch(in: assignmentName) else {
            fatalError("Invalid assignment name: \(assignmentName)")
        }
        
        return (Int(match.day)!, Int(match.year)!)
    }
}

extension Assignment {
    func getInput() -> String {
        let (day, year) = getIdentifier()
        let path = String(format: "Resources/years/%1$04d/%1$04d-%2$02d-input.txt", year, day)
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("Missing input file")
        }
        return content
    }
    
    func getInputData() -> Data {
        let (day, year) = getIdentifier()
        let path = String(format: "Resources/years/%1$04d/%1$04d-%2$02d-input.txt", year, day)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Missing input file")
        }
        return data
    }
    
    func mapInput<T>(separator: Character = "\n", _ transform: (String) throws -> T) rethrows -> [T] {
        try getInput()
            .split(separator: separator)
            .map {
                try transform(String($0))
            }
    }
    
    func compactMapInput<T>(separator: Character = "\n", _ transform: (String) throws -> T?) rethrows -> [T] {
        try getInput()
            .split(separator: separator)
            .compactMap {
                try transform(String($0))
            }
    }
    
    func getStreamedInput(delimiter: String = "\n", handler: (String) -> Void) {
        let (day, year) = getIdentifier()
        let path = String(format: "Resources/years/%1$04d/%1$04d-%2$02d-input.txt", year, day)
        guard let streamReader = StreamReader(path: path, delimiter: delimiter) else {
            fatalError("Missing input file")
        }
        
        for input in streamReader {
            handler(input)
        }
    }
}

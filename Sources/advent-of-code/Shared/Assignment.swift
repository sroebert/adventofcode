import Foundation

typealias AssignmentOutput = Sendable & CustomStringConvertible

protocol Assignment: Sendable {
    func getIdentifier() throws -> (day: Int, year: Int)
    
    func solvePart1() async throws -> AssignmentOutput
    func solvePart2() async throws -> AssignmentOutput
    
    var isSlowInDebug: Bool { get }
    var isSlowInRelease: Bool { get }
}

extension Assignment {
    func getIdentifier() throws -> (day: Int, year: Int) {
        let identifierRegex = /Assignment(?<year>[0-9]{4})(?<day>[0-9]{2})/
        
        let assignmentName = "\(Mirror(reflecting: self).subjectType)"
        guard let match = try? identifierRegex.wholeMatch(in: assignmentName) else {
            throw InputError(message: "Invalid assignment name: \(assignmentName)")
        }
        
        return (Int(match.day)!, Int(match.year)!)
    }
    
    var isSlowInDebug: Bool {
        return false
    }
    
    var isSlowInRelease: Bool {
        return false
    }
}

extension Assignment {
    private func getInputPath() async throws -> String {
        let (day, year) = try getIdentifier()
        
        let directoryPath = String(format: "Resources/years/%1$04d/", year)
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
        }
        
        let inputFilePath = directoryPath + String(format: "%1$04d-%2$02d-input.txt", year, day)
        
        if !FileManager.default.fileExists(atPath: inputFilePath) {
            guard let sessionCookie = ProcessInfo.processInfo.environment["ADVENT_OF_CODE_SESSION_COOKIE"]?.selfIfNotEmpty else {
                throw InputError(message: "Missing input file (\(year) - \(day)) and ADVENT_OF_CODE_SESSION_COOKIE is not defined")
            }
            
            var request = URLRequest(url: URL(string: "https://adventofcode.com/\(year)/day/\(day)/input")!)
            request.allHTTPHeaderFields = [
                "Cookie": "session=\(sessionCookie)"
            ]
            
            let inputData: (data: Data, response: URLResponse)
            do {
                inputData = try await URLSession.shared.data(for: request)
            } catch {
                throw InputError(message: "Missing input file (\(year) - \(day)) and failed to download input: \(error)")
            }
            
            guard let statusCode = (inputData.response as? HTTPURLResponse)?.statusCode else {
                throw InputError(message: "Invalid input data response")
            }
            
            guard statusCode == 200 else {
                let text = String(data: inputData.data, encoding: .utf8) ?? "None"
                throw InputError(message: "Invalid input data response \(statusCode): \(text)")
            }
            
            try inputData.data.write(to: URL(filePath: inputFilePath), options: .atomic)
        }
        
        return inputFilePath
    }
    
    func getInput() async throws -> String {
        let path = try await getInputPath()
        return try String(contentsOfFile: path, encoding: .utf8)
    }
    
    func getInputData() async throws -> Data {
        let path = try await getInputPath()
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    func mapInput<T>(separator: Character = "\n", _ transform: (String) throws -> T) async throws -> [T] {
        try await getInput()
            .split(separator: separator)
            .map {
                try transform(String($0))
            }
    }
    
    func compactMapInput<T>(separator: Character = "\n", _ transform: (String) throws -> T?) async throws -> [T] {
        try await getInput()
            .split(separator: separator)
            .compactMap {
                try transform(String($0))
            }
    }
    
    func getStreamedInput(delimiter: String = "\n", handler: (String) throws -> Void) async throws {
        let path = try await getInputPath()
        guard let streamReader = StreamReader(path: path, delimiter: delimiter) else {
            throw InputError(message: "Could not stream input")
        }
        
        for input in streamReader {
            try handler(input)
        }
    }
}

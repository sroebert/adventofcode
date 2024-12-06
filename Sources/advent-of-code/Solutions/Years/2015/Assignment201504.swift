import Foundation
import CryptoKit

struct Assignment201504: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await indexForMD5Prefix([0, 0, 15])
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await indexForMD5Prefix([0, 0, 0])
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func indexForMD5Prefix(_ prefix: [UInt8]) async throws -> Int {
        guard let input = try await getInput().split(separator: "\n").first else {
            throw InputError(message: "Invalid input")
        }
        
        let processorCount = min(4, ProcessInfo.processInfo.activeProcessorCount)
        
        let inputData = input.data(using: .utf8) ?? Data()
        
        return try await withThrowingTaskGroup(of: Int.self) { group in
            for taskIndex in 0..<processorCount {
                group.addTask {
                    var index = taskIndex
                    while !Task.isCancelled {
                        let indexData = String(index).data(using: .utf8) ?? Data()
                        let md5Hash = Insecure.MD5.hash(data: inputData + indexData)
                        if md5Hash.starts(with: prefix, by: <=) {
                            return index
                        }
            
                        index += processorCount
                    }
                    
                    throw CancellationError()
                }
            }
            
            guard let index = try await group.next() else {
                throw InputError(message: "Could not find index")
            }
            
            group.cancelAll()
            return index
        }
    }
}

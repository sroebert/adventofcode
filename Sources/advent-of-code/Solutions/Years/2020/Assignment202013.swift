struct Assignment202013: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let data = try await getDataDay1()
        
        var timestamp = data.departureTimestamp - 1
        
        repeat {
            timestamp += 1
            for id in data.busIds {
                if timestamp % id == 0 {
                    return id * (timestamp - data.departureTimestamp)
                }
            }
        } while true
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let data = try await getDataDay2()
        
        var timestamp = data.busIds[0]!
        var cycleTimestampOffset: UInt64? = nil
        
        var timestampStep = data.busIds[0]!
        
        var busIdIndex = data.busIds[1...].firstIndex { $0 != nil }!
        
        while true {
            if (timestamp + UInt64(busIdIndex)) % data.busIds[busIdIndex]! == 0 {
                guard let offset = cycleTimestampOffset else {
                    cycleTimestampOffset = timestamp
                    timestamp += timestampStep
                    continue
                }
                
                timestampStep = timestamp - offset
                guard let nextIndex = data.busIds[(busIdIndex+1)...].firstIndex(where: { $0 != nil }) else {
                    break
                }

                busIdIndex = nextIndex
                cycleTimestampOffset = nil
                continue
            }
            
            timestamp += timestampStep
        }
        
        return cycleTimestampOffset ?? 0
    }
    
    // MARK: - Utils
    
    private struct DataDay1 {
        var departureTimestamp: Int
        var busIds: [Int]
    }
    
    private func getDataDay1() async throws -> DataDay1 {
        let lines = try await getInput().split(separator: "\n")
        guard
            lines.count == 2,
            let departureTimestamp = Int(lines[0])
        else {
            throw InputError(message: "Invalid input")
        }
        
        let busIds = lines[1].split { $0 == "," }.compactMap { Int($0) }
        return DataDay1(departureTimestamp: departureTimestamp, busIds: busIds)
    }
    
    private struct DataDay2 {
        var busIds: [UInt64?]
    }
    
    private func getDataDay2() async throws -> DataDay2 {
        let lines = try await getInput().split(separator: "\n")
        guard lines.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        let busIds = lines[1].split { $0 == "," }.map { UInt64($0) }
        return DataDay2(busIds: busIds)
    }
}

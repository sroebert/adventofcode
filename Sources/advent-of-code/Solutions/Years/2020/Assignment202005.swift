struct Assignment202005: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let seats = try await getSeats()
        return seats.reduce(0) { max($0, $1.seatId) }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var foundSeats = Array<Bool>(repeating: false, count: 128 * 8)
        for i in 0..<8 {
            foundSeats[i] = true
            foundSeats[foundSeats.count - 1 - i] = true
        }
        
        let seats = try await getSeats()
        for seat in seats {
            foundSeats[seat.seatId] = true
        }
        
        var mySeatId = -1
        for i in 1..<foundSeats.count - 2 {
            if foundSeats[i-1] && !foundSeats[i] && foundSeats[i+1] {
                mySeatId = i
                break
            }
        }
        return mySeatId
    }
    
    // MARK: - Utils
    
    private struct Seat {
        var row: Int
        var column: Int
        
        var seatId: Int {
            return row * 8 + column
        }
        
        init(row: Int, column: Int) {
            self.row = row
            self.column = column
        }
        
        init?(_ string: Substring) {
            guard string.count == 10 else {
                return nil
            }
            
            let rowStart = string.startIndex
            let rowEnd = string.index(rowStart, offsetBy: 7)
            let rowPart = string[rowStart..<rowEnd].map {
                return $0 == "B" ? "1" : "0"
            }.joined()
            
            let columnStart = rowEnd
            let columnEnd = string.endIndex
            let columnPart = string[columnStart..<columnEnd].map {
                return $0 == "R" ? "1" : "0"
            }.joined()
            
            guard
                let row = Int(rowPart, radix: 2),
                let column = Int(columnPart, radix: 2)
            else {
                return nil
            }
            
            self.row = row
            self.column = column
        }
    }
    
    private func getSeats() async throws -> [Seat] {
        let lines = try await getInput().split(separator: "\n")
        let seats = lines.compactMap { Seat($0) }
        
        guard lines.count == seats.count else {
            throw InputError(message: "Invalid input")
        }
        
        return seats
    }
}

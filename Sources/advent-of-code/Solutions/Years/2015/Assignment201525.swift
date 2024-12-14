struct Assignment201525: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let (codeRow, codeColumn) = try await getRowColumn()
        
        var value = 20151125
        
        var startRow = 2
        var row = startRow
        var column = 1
        
        while true {
            value = (value * 252533) % 33554393
            
            if row == codeRow && column == codeColumn {
                return value
            }
            
            row -= 1
            column += 1
            
            if row == 0 {
                startRow += 1
                row = startRow
                column = 1
            }
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        return "N/A"
    }
    
    // MARK: - Utils
    
    private func getRowColumn() async throws -> (row: Int, column: Int) {
        let input = try await getInput()
        guard let match = input.firstMatch(of: /row (?<row>\d+), column (?<column>\d+)\./) else {
            throw InputError(message: "Invalid input")
        }
        
        return (
            row: Int(match.output.row) ?? 0,
            column: Int(match.output.column) ?? 0
        )
    }
}

import Foundation

let start = CFAbsoluteTimeGetCurrent()

let years = [
    Year.year2024
]

for year in years {
    print(
        """
        Year \(year.year)
        ---------
        """
    )
    
    for assignment in year.assignments {
        let (day, _) = assignment.getIdentifier()
        
        let assignmentStart = CFAbsoluteTimeGetCurrent()
        
        let solution1 = try await assignment.solvePart1()
        let solution2 = try await assignment.solvePart2()
        
        let assignmentDuration = round((CFAbsoluteTimeGetCurrent() - assignmentStart) * 1000) / 1000
        
        let dayString = String(
            format: "%2d: %@, %@ (%.3fs)",
            day,
            solution1.description.selfIfNotEmpty ?? "-",
            solution2.description.selfIfNotEmpty ?? "-",
            assignmentDuration
        )
        print(dayString)
    }
    
    print("")
}

let totalDuration = round((CFAbsoluteTimeGetCurrent() - start) * 1000) / 1000
print(String(format: "Duration %.2f seconds", totalDuration))

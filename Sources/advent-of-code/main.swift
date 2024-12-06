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
        
        let solution1 = try await assignment.solvePart1()
        let solution2 = try await assignment.solvePart2()
        
        let dayString = String(
            format: "%2d: %@, %@",
            day,
            solution1.description.selfIfNotEmpty ?? "-",
            solution2.description.selfIfNotEmpty ?? "-"
        )
        print(dayString)
    }
    
    print("")
}

let diff = CFAbsoluteTimeGetCurrent() - start
print("Took \(diff) seconds")

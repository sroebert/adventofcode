import Foundation

let start = CFAbsoluteTimeGetCurrent()

let years = [
    Year.year2015,
    Year.year2016,
    Year.year2017,
    Year.year2018,
    Year.year2019,
    Year.year2020,
    Year.year2021,
    Year.year2022,
    Year.year2023,
    Year.year2024,
]

let skipSlowInDebug = ["1", "true"].contains(ProcessInfo.processInfo.environment["SKIP_SLOW_IN_DEBUG"]?.lowercased() ?? "")
let runSlowInRelease = ["1", "true"].contains(ProcessInfo.processInfo.environment["RUN_SLOW_IN_RELEASE"]?.lowercased() ?? "")

for year in years {
    print(
        """
        Year \(year.year)
        ---------
        """
    )
    
    for (index, assignment) in year.assignments.enumerated() {
        guard (!skipSlowInDebug || !assignment.isSlowInDebug) && (runSlowInRelease || !assignment.isSlowInRelease) else {
            print(String(
                format: "%2d: Skipped",
                index + 1
            ))
            continue
        }
        
        do {
            let assignmentStart = CFAbsoluteTimeGetCurrent()
            
            let solution1 = try await assignment.solvePart1()
            let solution2 = try await assignment.solvePart2()
            
            let assignmentDuration = round((CFAbsoluteTimeGetCurrent() - assignmentStart) * 1000) / 1000
            
            print(String(
                format: "%2d: %@, %@ (%.3fs)",
                index + 1,
                solution1.description.selfIfNotEmpty ?? "-",
                solution2.description.selfIfNotEmpty ?? "-",
                assignmentDuration
            ))
        } catch {
            print(String(
                format: "%2d: Error - %@",
                index + 1,
                "\(error)"
            ))
        }
    }
    
    print("")
}

let totalDuration = round((CFAbsoluteTimeGetCurrent() - start) * 1000) / 1000
print(String(format: "Duration %.2f seconds", totalDuration))

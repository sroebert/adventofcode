import RegexBuilder
struct Assignment201506: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var lights = [[Bool]](repeating: .init(repeating: false, count: 1000), count: 1000)
        for instruction in try await getInstructions() {
            switch instruction.action {
            case .turnOn:
                iterate(over: instruction) {
                    lights[$0.x][$0.y] = true
                }
            case .turnOff:
                iterate(over: instruction) {
                    lights[$0.x][$0.y] = false
                }
            case .toggle:
                iterate(over: instruction) {
                    lights[$0.x][$0.y].toggle()
                }
            }
        }
        
        return lights.reduce(0) { $0 + $1.count { $0 }}
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var lights = [[Int]](repeating: .init(repeating: 0, count: 1000), count: 1000)
        for instruction in try await getInstructions() {
            switch instruction.action {
            case .turnOn:
                iterate(over: instruction) {
                    lights[$0.x][$0.y] += 1
                }
            case .turnOff:
                iterate(over: instruction) {
                    lights[$0.x][$0.y] = max(0, lights[$0.x][$0.y] - 1)
                }
            case .toggle:
                iterate(over: instruction) {
                    lights[$0.x][$0.y] += 2
                }
            }
        }
        
        return lights.reduce(0) { $0 + $1.reduce(0, +) }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Point: Hashable {
        var x: Int
        var y: Int
    }
    
    private enum Action: String {
        case toggle
        case turnOn = "turn on"
        case turnOff = "turn off"
    }
    
    private struct Instruction {
        var action: Action
        var from: Point
        var to: Point
    }
    
    private func getInstructions() async throws -> [Instruction] {
        let action = Reference(Action.self)
        let fromX = Reference(Int.self)
        let fromY = Reference(Int.self)
        let toX = Reference(Int.self)
        let toY = Reference(Int.self)
        let regex = Regex {
            TryCapture(as: action) {
                OneOrMore(.any)
            } transform: {
                Action(rawValue: String($0))
            }
            " "
            TryCapture(as: fromX) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
            ","
            TryCapture(as: fromY) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
            " through "
            TryCapture(as: toX) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
            ","
            TryCapture(as: toY) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
        }
        
        return try await getInput()
            .split(separator: "\n")
            .compactMap { (line: Substring) -> Instruction? in
                guard let match = line.wholeMatch(of: regex) else {
                    return nil
                }
                return Instruction(
                    action: match[action],
                    from: Point(x: match[fromX], y: match[fromY]),
                    to: Point(x: match[toX], y: match[toY])
                )
            }
    }
    
    private func iterate(over instruction: Instruction, action: (Point) -> Void) {
        for x in instruction.from.x...instruction.to.x {
            for y in instruction.from.y...instruction.to.y {
                action(Point(x: x, y: y))
            }
        }
    }
}

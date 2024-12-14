import RegexBuilder
struct Assignment202413: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let clawMachines = try await getClawMachines()
        return await clawMachines.concurrentCount {
            $0.costToWinPrize
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let clawMachines = try await getClawMachines()
        
        let correction = 10000000000000
        let correctedClawMachines = clawMachines.map { clawMachine in
            var clawMachine = clawMachine
            clawMachine.prize.x += correction
            clawMachine.prize.y += correction
            return clawMachine
        }
        
        return await correctedClawMachines.concurrentCount {
            $0.costToWinPrize
        }
    }
    
    // MARK: - Utils
    
    private struct ClawMachine {
        var buttonA: Point
        var buttonB: Point
        var prize: Point
        
        var costToWinPrize: Int {
            // Equations you get when solving:
            // pX = aX * a + bX * b
            // py = aY * a + bY * b
            
            let a = (prize.y * buttonB.x - prize.x * buttonB.y) / (buttonA.y * buttonB.x - buttonA.x * buttonB.y)
            let b = (prize.x * buttonA.y - prize.y * buttonA.x) / (buttonA.y * buttonB.x - buttonA.x * buttonB.y)
            guard
                a * buttonA.x + b * buttonB.x == prize.x,
                a * buttonA.y + b * buttonB.y == prize.y
            else {
                return 0
            }
            
            return a * 3 + b
        }
    }
    
    private func getClawMachines() async throws -> [ClawMachine] {
        let input = try await getInput()
        
        let aX = Reference(Int.self)
        let aY = Reference(Int.self)
        let bX = Reference(Int.self)
        let bY = Reference(Int.self)
        let prizeX = Reference(Int.self)
        let prizeY = Reference(Int.self)
        
        func captureInt(_ reference: Reference<Int>) -> TryCapture<(Substring, Int)> {
            TryCapture(as: reference) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
        }
        
        let regex = Regex {
            "Button A: X+"
            captureInt(aX)
            ", Y+"
            captureInt(aY)
            "\nButton B: X+"
            captureInt(bX)
            ", Y+"
            captureInt(bY)
            "\nPrize: X="
            captureInt(prizeX)
            ", Y="
            captureInt(prizeY)
        }
        
        return input.matches(of: regex).map {
            ClawMachine(
                buttonA: Point(
                    x: $0[aX],
                    y: $0[aY]
                ),
                buttonB: Point(
                    x: $0[bX],
                    y: $0[bY]
                ),
                prize: Point(
                    x: $0[prizeX],
                    y: $0[prizeY]
                )
            )
        }
    }
}

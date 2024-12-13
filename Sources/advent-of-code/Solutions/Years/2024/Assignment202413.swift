import RegexBuilder
struct Assignment202413: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let clawMachines = try await getClawMachines()
        return await clawMachines.concurrentCount {
            $0.costToWinPrice
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
            $0.costToWinPrice
        }
    }
    
    // MARK: - Utils
    
    private struct ClawMachine {
        var buttonA: Point
        var buttonB: Point
        var prize: Point
        
        var costToWinPrice: Int {
            var minimumCost = Int.max
            for b in 1...100 {
                for a in 1...100 {
                    if buttonA.x * a + buttonB.x * b == prize.x &&
                        buttonA.y * a + buttonB.y * b == prize.y {
                        
                        let cost = a * 3 + b
                        if cost < minimumCost {
                            minimumCost = cost
                        }
                    }
                }
            }
            
            return minimumCost == Int.max ? 0 : minimumCost
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

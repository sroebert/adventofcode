import Foundation
import Collections

struct Assignment202411: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let stones = try await getStones()
        return stoneCount(afterBlinking: 25, initialStones: stones)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let stones = try await getStones()
        return stoneCount(afterBlinking: 75, initialStones: stones)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct BlinkID: Hashable {
        var stone: Int
        var blinkCount: Int
    }
    
    private func getStones() async throws -> [Int] {
        try await getInput()
            .split(whereSeparator: \.isWhitespace)
            .compactMap { Int($0) }
    }
    
    private func stoneCount(afterBlinking blinkCount: Int, initialStones: [Int]) -> Int {
        var blinkIdsToCalculate = OrderedSet<BlinkID>()
        
        var stack = initialStones.map { BlinkID(stone: $0, blinkCount: blinkCount) }
        var stackIndex = 0
        
        while stackIndex < stack.count {
            let blinkId = stack[stackIndex]
            stackIndex += 1
            
            let result = blinkIdsToCalculate.append(blinkId)
            guard result.inserted && blinkId.blinkCount > 1 else {
                continue
            }
            
            blink(forStone: blinkId.stone).forEach {
                let nextBlinkId = BlinkID(stone: $0, blinkCount: blinkId.blinkCount - 1)
                stack.append(nextBlinkId)
            }
        }
        
        var blinkMapping: [BlinkID: Int] = [:]
        while blinkIdsToCalculate.last?.blinkCount == 1 {
            let blinkId = blinkIdsToCalculate.removeLast()
            blinkMapping[blinkId] = blink(forStone: blinkId.stone).count
        }
        
        while !blinkIdsToCalculate.isEmpty {
            let blinkId = blinkIdsToCalculate.removeLast()
            
            blinkMapping[blinkId] = blink(forStone: blinkId.stone).reduce(0) { total, stone in
                let stoneBlinkId = BlinkID(stone: stone, blinkCount: blinkId.blinkCount - 1)
                return total + (blinkMapping[stoneBlinkId] ?? 0)
            }
        }
        
        return initialStones.reduce(0) {
            $0 + (blinkMapping[BlinkID(stone: $1, blinkCount: blinkCount)] ?? 0)
        }
    }
    
    private func blink(forStone stone: Int) -> [Int] {
        if stone == 0 {
            return [1]
        }
        
        let halfDigitCount = stone.numberOfDigits / 2
        if floor(halfDigitCount) == halfDigitCount {
            let factor = Int(pow(10, halfDigitCount))
            let leftStone = stone / factor
            let rightStone = stone - leftStone * factor
            return [leftStone, rightStone]
        }
        
        return [stone * 2024]
    }
}

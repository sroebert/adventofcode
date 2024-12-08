struct Assignment202408: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let map = try await getMap()
        let mapRange = 0..<map.size
        
        var antinodeMap = Array(repeating: Array(repeating: false, count: map.size), count: map.size)
        var count = 0
        
        for (_, antennas) in map.antennas {
            for antennaCombination in antennas.combinations(ofCount: 2) {
                let firstAntinodeX = antennaCombination[0].x + (antennaCombination[0].x - antennaCombination[1].x)
                let firstAntinodeY = antennaCombination[0].y + (antennaCombination[0].y - antennaCombination[1].y)
                if mapRange.contains(firstAntinodeX) && mapRange.contains(firstAntinodeY) && !antinodeMap[firstAntinodeY][firstAntinodeX] {
                    count += 1
                    antinodeMap[firstAntinodeY][firstAntinodeX] = true
                }
                
                let secondAntinodeX = antennaCombination[1].x - (antennaCombination[0].x - antennaCombination[1].x)
                let secondAntinodeY = antennaCombination[1].y - (antennaCombination[0].y - antennaCombination[1].y)
                if mapRange.contains(secondAntinodeX) && mapRange.contains(secondAntinodeY) && !antinodeMap[secondAntinodeY][secondAntinodeX] {
                    count += 1
                    antinodeMap[secondAntinodeY][secondAntinodeX] = true
                }
            }
        }
        
        return count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let map = try await getMap()
        let mapRange = 0..<map.size
        
        var antinodeMap = Array(repeating: Array(repeating: false, count: map.size), count: map.size)
        var count = 0
        
        for (_, antennas) in map.antennas {
            for antennaCombination in antennas.combinations(ofCount: 2) {
                let diffX = antennaCombination[1].x - antennaCombination[0].x
                let diffY = antennaCombination[1].y - antennaCombination[0].y
                
                let gcd = gcd(diffX, diffY)
                let stepX = diffX / gcd
                let stepY = diffY / gcd
                
                var x = antennaCombination[0].x
                var y = antennaCombination[0].y
                repeat {
                    if !antinodeMap[y][x] {
                        antinodeMap[y][x] = true
                        count += 1
                    }
                    
                    x -= stepX
                    y -= stepY
                } while mapRange.contains(x) && mapRange.contains(y)
                
                x = antennaCombination[0].x + stepX
                y = antennaCombination[0].y + stepY
                while mapRange.contains(x) && mapRange.contains(y) {
                    if !antinodeMap[y][x] {
                        antinodeMap[y][x] = true
                        count += 1
                    }
                    
                    x += stepX
                    y += stepY
                }
            }
        }
        
        return count
    }
    
    // MARK: - Utils
    
    private struct Antenna {
        var x: Int
        var y: Int
    }
    
    private struct Map {
        var size: Int
        var antennas: [Character: [Antenna]]
    }
    
    private func getMap() async throws -> Map {
        var map = Map(size: 0, antennas: [:])
        
        var y = 0
        try await getStreamedInput { line in
            map.size = Int(line.count)
            
            line.enumerated().forEach { x, character in
                if character != "." {
                    var antennas = map.antennas[character, default: []]
                    antennas.append(Antenna(x: x, y: y))
                    map.antennas[character] = antennas
                }
            }
            
            y += 1
        }
        
        return map
    }
    
    private func gcd(_ a: Int, _ b: Int) -> Int {
        var a = abs(a)
        var b = abs(b)
        
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        
        return a
    }
}

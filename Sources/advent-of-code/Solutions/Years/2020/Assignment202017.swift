import Foundation

struct Assignment202017: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var cubes: Set<Cube3D> = try await getActiveCubes()
        for _ in 0..<6 {
            cycle(&cubes)
        }
        return cubes.count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var cubes: Set<Cube4D> = try await getActiveCubes()
        for _ in 0..<6 {
            cycle(&cubes)
        }
        return cubes.count
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private protocol Cube: Hashable {
        init(x: Int, y: Int)
        init(coordinates: [Int])
        
        var coordinates: [Int] { get }
    }
    
    private func neighbors<C: Cube>(for cube: C) -> [C] {
        let coordinates = cube.coordinates
        let dimensions = coordinates.count
        let neighborCount = Int(pow(3, Double(dimensions)))
        
        return (0..<neighborCount).compactMap { i in
            let coordinateOffsets = (0..<dimensions).map { dimension -> Int in
                let division = Int(pow(3, Double(dimension)))
                return ((i / division) % 3) - 1
            }
            
            guard coordinateOffsets.contains(where: { $0 != 0 }) else {
                return nil
            }
            
            return C(coordinates: zip(coordinates, coordinateOffsets).map { $0 + $1 })
        }
    }
    
    private struct Cube3D: Cube, Hashable {
        var x: Int
        var y: Int
        var z: Int
        
        var coordinates: [Int] {
            return [x, y, z]
        }
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
            z = 0
        }
        
        init(coordinates: [Int]) {
            self.x = coordinates[0]
            self.y = coordinates[1]
            self.z = coordinates[2]
        }
    }
    
    private struct Cube4D: Cube, Hashable {
        var x: Int
        var y: Int
        var z: Int
        var w: Int
        
        var coordinates: [Int] {
            return [x, y, z, w]
        }
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
            z = 0
            w = 0
        }
        
        init(coordinates: [Int]) {
            self.x = coordinates[0]
            self.y = coordinates[1]
            self.z = coordinates[2]
            self.w = coordinates[3]
        }
    }
    
    private func getActiveCubes<T: Cube>() async throws -> Set<T> {
        var activeCubes = Set<T>()
        try await getInput()
            .split(separator: "\n")
            .enumerated()
            .forEach { y, line in
                line.enumerated().forEach { x, character in
                    if character == "#" {
                        activeCubes.insert(T(x: x, y: y))
                    }
                }
            }
        return activeCubes
    }
    
    private func cycle<T: Cube>(_ cubes: inout Set<T>) {
        var newCubes = cubes
        var possibleNewCubes: [T:Int] = [:]
        
        for cube in cubes {
            var activeCount = 0
            for neighbor in neighbors(for: cube) {
                if cubes.contains(neighbor) {
                    activeCount += 1
                } else {
                    possibleNewCubes[neighbor] = (possibleNewCubes[neighbor] ?? 0) + 1
                }
            }
            
            if activeCount < 2 || activeCount > 3 {
                newCubes.remove(cube)
            }
        }
        
        for (cube, count) in possibleNewCubes {
            if count == 3 {
                newCubes.insert(cube)
            }
        }
        
        cubes = newCubes
    }
}

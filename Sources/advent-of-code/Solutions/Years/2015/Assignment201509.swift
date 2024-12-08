import Algorithms
import RegexBuilder

struct Assignment201509: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await determineDistance(using: <)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let map = try await getMap()
        
        var maxDistance = 0
        for route in (0..<map.placeCount).permutations() {
            var distance = 0
            for i in 1..<route.count {
                distance += map.getDistance(from: route[i-1], to: route[i])
            }
            
            if distance > maxDistance {
                maxDistance = distance
            }
        }
        
        return maxDistance
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Route {
        var endId: Int
        var ids: Set<Int>
        var distance: Int = 0
    }
    
    private struct Map {
        var placeCount: Int
        var distances: [DistanceId: Int]
        
        func getDistance(from fromId: Int, to toId: Int) -> Int {
            return
                distances[.init(fromId: fromId, toId: toId)] ??
                distances[.init(fromId: toId, toId: fromId)] ??
                0
        }
    }
    
    private struct DistanceId: Hashable {
        var fromId: Int
        var toId: Int
    }
    
    private func getMap() async throws -> Map {
        var routeIds: [String:Int] = [:]
        var distances: [DistanceId: Int] = [:]
        
        let fromNameRef = Reference(String.self)
        let toNameRef = Reference(String.self)
        let distanceRef = Reference(Int.self)
        let regex = Regex {
            TryCapture(as: fromNameRef) {
                OneOrMore(.word)
            } transform: {
                String($0)
            }
            " to "
            TryCapture(as: toNameRef) {
                OneOrMore(.word)
            } transform: {
                String($0)
            }
            " = "
            TryCapture(as: distanceRef) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
        }
        
        for line in try await getInput().split(separator: "\n") {
            guard let match = line.wholeMatch(of: regex) else {
                continue
            }
            
            let fromName = match[fromNameRef]
            let fromId = routeIds[fromName] ?? routeIds.count
            routeIds[fromName] = fromId
            
            let toName = match[toNameRef]
            let toId = routeIds[toName] ?? routeIds.count
            routeIds[toName] = toId
            
            let id = DistanceId(fromId: fromId, toId: toId)
            let distance = match[distanceRef]
            
            distances[id] = distance
        }
        
        return Map(placeCount: routeIds.count, distances: distances)
    }
    
    private func determineDistance(using compare: (Int, Int) -> Bool) async throws -> Int {
        let map = try await getMap()
        
        var routes = (0..<map.placeCount).map { Route(endId: $0, ids: Set([$0])) }
        repeat {
            let currentRoute = routes.removeFirst()
            if currentRoute.ids.count == map.placeCount {
                return currentRoute.distance
            }
            
            for placeId in 0..<map.placeCount {
                guard !currentRoute.ids.contains(placeId) else {
                    continue
                }
                
                var newRoute = currentRoute
                newRoute.ids.insert(placeId)
                newRoute.endId = placeId
                newRoute.distance += map.getDistance(from: currentRoute.endId, to: placeId)
                
                let insertionIndex = routes.binarySearch { compare($0.distance, newRoute.distance) }
                routes.insert(newRoute, at: insertionIndex)
            }
            
        } while true
    }
}

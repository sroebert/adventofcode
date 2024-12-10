struct Point: Hashable {
    var x: Int
    var y: Int
    
    static func +=(lhs: inout Point, rhs: Point) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func +(lhs: Point, rhs: Point) -> Point {
        var newPoint = lhs
        newPoint += rhs
        return newPoint
    }
    
    static func -=(lhs: inout Point, rhs: Point) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    static func -(lhs: Point, rhs: Point) -> Point {
        var newPoint = lhs
        newPoint -= rhs
        return newPoint
    }
    
    var north: Point { Point(x: x, y: y + 1) }
    var northEast: Point { Point(x: x + 1, y: y + 1) }
    var northWest: Point { Point(x: x - 1, y: y + 1) }
    
    var east: Point { Point(x: x + 1, y: y) }
    
    var south: Point { Point(x: x, y: y - 1) }
    var southEast: Point { Point(x: x + 1, y: y - 1) }
    var southWest: Point { Point(x: x - 1, y: y - 1) }
    
    var west: Point { Point(x: x - 1, y: y) }
    
    var cardinalNeighbors: [Point] {
        [north, east, south, west]
    }
    
    var diagonalNeighbors: [Point] {
        [northEast, southEast, southWest, northWest]
    }
    
    var allNeighbors: [Point] {
        [north, northEast, east, southEast, south, southWest, west, northWest]
    }
}

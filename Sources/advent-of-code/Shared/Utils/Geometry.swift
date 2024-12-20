import Foundation

struct Point: Hashable {
    var x: Int
    var y: Int
    
    static let zero = Point(x: 0, y: 0)
    
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
    
    static func *=(lhs: inout Point, rhs: Int) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    
    static func *(lhs: Point, rhs: Int) -> Point {
        var newPoint = lhs
        newPoint *= rhs
        return newPoint
    }
    
    static func *(lhs: Int, rhs: Point) -> Point {
        var newPoint = rhs
        newPoint *= lhs
        return newPoint
    }
    
    var north: Point { Point(x: x, y: y - 1) }
    var northEast: Point { Point(x: x + 1, y: y - 1) }
    var northWest: Point { Point(x: x - 1, y: y - 1) }
    
    var east: Point { Point(x: x + 1, y: y) }
    
    var south: Point { Point(x: x, y: y + 1) }
    var southEast: Point { Point(x: x + 1, y: y + 1) }
    var southWest: Point { Point(x: x - 1, y: y + 1) }
    
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
    
    func distance(to point: Point) -> Double {
        let diffX = Double(x - point.x)
        let diffY = Double(y - point.y)
        
        if diffX == 0 {
            return abs(diffY)
        }
        if diffY == 0 {
            return abs(diffX)
        }
        return sqrt(diffX * diffX + diffY * diffY)
    }
}

struct Size {
    var width: Int
    var height: Int
}

struct Rect {
    var origin: Point
    var size: Size
    
    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    init (x: Int, y: Int, width: Int, height: Int) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
    
    func contains(_ point: Point) -> Bool {
        return (
            point.x >= origin.x &&
            point.x <= origin.x + size.width &&
            point.y >= origin.y &&
            point.y <= origin.y + size.height
        )
    }
}

enum CardinalDirection {
    case north
    case south
    case east
    case west
    
    var step: Point {
        switch self {
        case .north: return Point(x: 0, y: -1)
        case .south: return Point(x: 0, y: 1)
        case .east: return Point(x: 1, y: 0)
        case .west: return Point(x: -1, y: 0)
        }
    }
    
    mutating func rotateLeft() {
        self = rotatedLeft
    }
    
    var rotatedLeft: CardinalDirection {
        switch self {
        case .north: return .west
        case .west: return .south
        case .south: return .east
        case .east: return .north
        }
    }
    
    mutating func rotateRight() {
        self = rotatedRight
    }
    
    var rotatedRight: CardinalDirection {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }
}

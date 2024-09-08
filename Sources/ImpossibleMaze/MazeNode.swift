import Foundation
import SwiftGodot

@Godot(.tool)
public class MazeNode: Node3D {
    
    @Export()
    public var width: Int = 33
    
    @Export()
    public var height: Int = 33
    
    lazy var maze: [[Int]] = Array(repeating: Array(repeating: 1, count: width), count: height)
    
    @Export()
    public var start: Vector2 = Vector2(x: 1, y: 0)
    
    @Export()
    public lazy var end: Vector2 = Vector2(x: Float(width - 2), y: Float(height - 1))
    
    @SceneTree(path: "PrototypeWall")
    var prototypeWall: StaticBody3D?
    
    // Directions for moving in the maze (up, right, down, left)
    let directions = [Vector2(x: 0, y: -1), Vector2(x: 1, y: 0), Vector2(x: 0, y: 1), Vector2(x: -1, y: 0)]
    
    public required init() {
        super.init()
        self.generateMaze()
    }
    
    required init(nativeHandle: UnsafeRawPointer) {
        super.init(nativeHandle: nativeHandle)
        self.generateMaze()
    }
    
    public override func _ready() {
        for y in 0..<height {
            for x in 0..<width {
                if maze[y][x] == 1 {
                    placeWall(at: Vector2(x: Float(x), y: Float(y)))
                }
            }
        }
    }
    
    private func placeWall(at position: Vector2) {
        guard let newWall = prototypeWall?.duplicate() as? StaticBody3D else {
            return
        }
        
        newWall.position = Vector3(x: position.x, y: 0, z: position.y)
        newWall.visible = true
        print(newWall.position)
        addChild(node: newWall)
    }
    
    // Check if a position is valid and within bounds
    func isValid(_ x: Int, _ y: Int) -> Bool {
        return x > 0 && x < width - 1 && y > 0 && y < height - 1
    }
    
    // Depth-First Search algorithm to carve the maze
    func dfs(_ x: Int, _ y: Int) {
        // Mark the current cell as open (0)
        maze[y][x] = 0
        
        // Randomly shuffle the directions to create a randomized maze
        let shuffledDirections = directions.shuffled()
        
        for direction in shuffledDirections {
            let nx = x + Int(direction.x) * 2
            let ny = y + Int(direction.y) * 2
            
            if isValid(nx, ny) && maze[ny][nx] == 1 {
                // Carve a path between the current cell and the next
                maze[y + Int(direction.y)][x + Int(direction.x)] = 0
                dfs(nx, ny)
            }
        }
    }
    
    // Generate the maze by starting from a random cell
    func generateMaze() {
        // DFS never makes fully inclosed sections so it doesn't matter where we start as long as it's inside
        dfs(1, 1)
        placeStartAndEnd()
    }
    
    // Place the start (top-left) and end (bottom-right) points in the maze
    func placeStartAndEnd() {
        // Start point is at the top-left
        let start = self.start
        maze[Int(start.y)][Int(start.x)] = 0 // Ensure the start is open
        
        // End point is at the bottom-right
        let end = self.end
        maze[Int(end.y)][Int(end.x)] = 0 // Ensure the end is open
    }
}

extension Vector2 {
    init(x: Int, y: Int) {
        self.init(x: Float(x), y: Float(y))
    }
}

extension Array where Element == Array<Int> {
    subscript(_ point: Vector2) -> Int {
        get {
            self[Int(point.y)][Int(point.x)]
        }
        mutating set(newValue) {
            self[Int(point.y)][Int(point.x)] = newValue
        }
    }
}

import SwiftGodot

public let godotTypes: [Wrapped.Type] = [
    Player.self,
    MazeNode.self,
    Screen3D.self,
    Prop.self,
    UserInterface.self
]

#initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)

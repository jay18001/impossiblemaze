import Foundation
//import SwiftGodot
//import SwiftGodotKit
import ImpossibleMaze
import CoreGraphics
#if canImport(UIKit)
import UIKit
#endif

//
//guard let packPath = Bundle.module.path(forResource: "ImpossibleMaze", ofType: "pck") else {
//    fatalError("Could not load Pack")
//}
//
//func loadScene(scene: SceneTree) {
//}
//
//func registerTypes (level: GDExtension.InitializationLevel) {
//    switch level {
//    case .scene:
//        #warning("uncomment this line if type casting / lookups don't work")
//        // ImpossibleMaze.godotTypes.forEach { register(type: $0) }
//        break
//    default:
//        break
//    }
//}
//
//runGodot(
//    args: [
//        "--main-pack", packPath
//    ],
//    initHook: registerTypes,
//    loadScene: loadScene,
//    loadProjectSettings: { settings in }
//)

#if canImport(UIKit)
let mazeGen = MazeGenerator()
let maze = mazeGen.wilsonsMaze(width: 32, height: 32)
let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

let img = renderer.image { ctx in
    ctx.cgContext.setFillColor(UIColor.red.cgColor)
    ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
    ctx.cgContext.setLineWidth(10)

    let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
    ctx.cgContext.addRect(rectangle)
    ctx.cgContext.drawPath(using: .fillStroke)
}



print("stop")

#endif



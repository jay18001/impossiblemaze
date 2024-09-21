import Foundation
import SwiftGodot

@Godot(.gameplay)
class UserInterface: Control {
    
    @SceneTree(path: "InteractionLabel")
    var interactionLabel: Label?
    
    override func _ready() {
        super._ready()
        
        if let interactAction = InputMap.actionGetEvents(action: .interact).first {
            interactionLabel?.text = "Press \(interactAction.asText()) to pick up"
        }
    }
    
    func showInteraction() {
        interactionLabel?.visible = true
    }
    
    func hideInteraction() {
        interactionLabel?.visible = false
    }
    
}

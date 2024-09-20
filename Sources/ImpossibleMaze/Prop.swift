import Foundation
import SwiftGodot

@Godot(.tool)
public class Prop: RigidBody3D {
    
    // This controls how much it will turn if it bumps into something.
    // Change this to suit your needs.
    let maxAngularDamp = 10.0
    
    @Export
    public var gravity: Double = -24.8
    
    @Export//(float, 0.0, 90.0, 0.05)
    public var snapVelocity: Double = 20.0
    @Export()//(float, 0.0, 90.0, 0.05)
    public var letGoDistance: Double = 0.8
    
    @Export()//(0.0, 1.0, 0.05)
    public var mouseXSensitivity: Float = 0.1
    @Export()//(0.0, 1.0, 0.05)
    public var mouseYSensitivity: Float = 0.1
    
    var propContainer: Node3D?
    
    public override func _input(event: InputEvent) {
        if let event = event as? InputEventMouseMotion, propContainer != nil, Input.isActionPressed(action: .inspect) {
            // rotate the player body
            rotateY(angle: Double(-event.relative.x * mouseXSensitivity).degreesToRadians)
            
            // rotate the camera on x axis (look up or down)
            rotateX(angle: Double(-event.relative.y * mouseYSensitivity).degreesToRadians)
        }
    }
    
    public override func _process(delta: Double) {
        if propContainer != nil {
            move()
        }
    }
    
    
    // This method tries to move the prop towards the prop container origin.
    // However, if it is colliding an object and the distance of the prop container
    // is too far away, it will detach itself.
    func move() {
        guard let propContainer else {
            return
        }
        // Calculates the direction of the prop container from the prop
        let direction = globalTransform.origin.directionTo(propContainer.globalTransform.origin).normalized()
        
        // Calculates the distance of the prop to the prop container
        let distance = globalTransform.origin.distanceTo(propContainer.globalTransform.origin)
        
        // Moves the prop towards the prop container node.
        linearVelocity = direction * distance * snapVelocity
        
        // If the object is too far away, release the object. This prevents the prop
        // from trying to clip through other objects.
        if getCollidingBodies().isEmpty() && distance > letGoDistance {
            detach()
        }
    }
    
    // This method will attempt to "attach" this prop to the causer.
    // I use the word "attach" loosely here as it does not actually modify
    // the node structure, but rather marks a node as a point of reference
    // for positioning.
    //
    // This also disables the collision layer and collision mask.
    //
    // This method should be called by the causer.
    public func attach(causer: Node3D) {
        collisionMask = CollisionMask.attachMode
        propContainer = causer
        angularDamp = maxAngularDamp
    }
    
    
    // The opposite of detach. This will reset the collision mask
    // and the marked prop container.
    //
    // This method should be called by the causer.
    public func detach() {
        collisionMask = CollisionMask.detachMode
        propContainer = nil
        angularDamp = 0
    }
    
}

extension Vector3 {
    static func >(lhs: Vector3, rhs: Double) -> Bool {
        return lhs.x > Float(rhs) && lhs.y > Float(rhs) && lhs.z > Float(rhs)
    }
}

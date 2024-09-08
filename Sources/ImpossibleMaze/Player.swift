import Foundation

import SwiftGodot

@Godot(.gameplay)
public class Player: CharacterBody3D {
    
    var direction = Vector3()
    var moveVelocity = Vector3()
    var isSprinting = false
    
    @Export
    public var gravity: Double = -24.8
    
    @Export
    public var maxSpeed: Double = 40
    
    @Export
    public var jumpSpeed: Double = 18
    
    @Export
    public var acceleration: Double = 20
    
    @Export
    public var sprintAcceleration: Double = 40
    
    @Export
    public var deceleration: Double = 16
    
    @Export
    public var maxSlopeAngle: Double = 40
    
    @Export
    public var mouseSensitivity: Double = 0.05
    
    @SceneTree(path: "Piviot/Camera")
    var camera: Camera3D?
    
    @SceneTree(path: "Piviot")
    var piviot: Node3D?
    
    @SceneTree(path: "Piviot/Flashlight")
    var flashlight: SpotLight3D?
    
    public override func _ready() {
        super._ready()
        Input.mouseMode = .captured
    }
    
    public override func _physicsProcess(delta: Double) {
        processInput(delta: delta)
        processMovement(delta: delta)
        super._physicsProcess(delta: delta)
    }
    
    func processInput(delta: Double) {
        direction = Vector3()
        
        guard let cameraTransform = camera?.globalTransform else {
            return
        }
        
        var inputVector = Vector2()
        
        if Input.isActionPressed(action: "move_forward") {
            inputVector.y += 1
        }
        if Input.isActionPressed(action: "move_back") {
            inputVector.y -= 1
        }
        if Input.isActionPressed(action: "move_left") {
            inputVector.x -= 1
        }
        if Input.isActionPressed(action: "move_right") {
            inputVector.x += 1
        }
        
        isSprinting = Input.isActionPressed(action: "sprint")
        
        if Input.isActionJustPressed(action: "flashlight_toggle") {
            flashlight?.visible.toggle()
        }
        
        inputVector = inputVector.normalized()
        
        direction = (cameraTransform.basis * Vector3(x: inputVector.x, y: 0, z: -inputVector.y)).normalized()
        
        if isOnFloor() {
            if Input.isActionJustPressed(action: "move_jump") {
                moveVelocity.y = Float(jumpSpeed)
            }
        }
        
        if Input.isActionJustPressed(action: "ui_cancel") {
            Input.mouseMode = if Input.mouseMode == .visible {
                 .captured
            } else {
                 .visible
            }
        }
    }
    
    func processMovement(delta: Double) {
        direction.y = 0
        direction = direction.normalized()
        
        moveVelocity.y += Float(delta * gravity)
        
        var horiazontalVelocity = moveVelocity
        horiazontalVelocity.y = 0
        
        var target = direction
        target *= maxSpeed
        
        let acceleration = isSprinting ? sprintAcceleration : acceleration
        
        horiazontalVelocity = horiazontalVelocity.lerp(to: target, weight: acceleration * delta)
        velocity.x = horiazontalVelocity.x
        velocity.z = horiazontalVelocity.z
        velocity.y = moveVelocity.y
        
        moveAndSlide()
    }
    
    public override func _input(event: InputEvent) {
        super._input(event: event)
       
        guard let mouseMotion = event as? InputEventMouseMotion, let piviot, Input.mouseMode == .captured else {
            return
        }
        
        piviot.rotateX(angle: Double(mouseMotion.relative.y) * mouseSensitivity)
        self.rotateY(angle: Double(mouseMotion.relative.x) * mouseSensitivity * -1)
        
        var cameraRotation = piviot.rotationDegrees
        cameraRotation.x = (-50.0...35.0).clamp(cameraRotation.x)
        piviot.rotationDegrees = cameraRotation
    }
}

extension Vector3 {
    static func *(lhs: Vector3, rhs: Float) -> Vector3 {
        return Vector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

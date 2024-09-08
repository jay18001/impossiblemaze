import Foundation
import SwiftGodot

@Godot(.tool)
public class Screen3D: Node3D {
    
    // Used for checking if the mouse is inside the Area3D.
    var isMouseInside = false
    // The last processed input touch/mouse event. To calculate relative movement.
    var lastEventPos2D: Vector2?
    // The time of the last event in seconds since engine start.
    var lastEventTime: Float = -1.0
    
    @SceneTree(path: "SubViewport")
    var nodeViewport: SubViewport?
    
    @SceneTree(path: "Quad")
    var nodeQuad: MeshInstance3D?
    
    @SceneTree(path: "Quad/Area3D")
    var nodeArea: Area3D?
    
    public override func _ready() {
        nodeArea?.mouseEntered.connect(mouse_entered_area)
        nodeArea?.mouseExited.connect(mouse_exited_area)
        nodeArea?.inputEvent.connect(mouse_input_event)
        
        // If the material is NOT set to use billboard settings, then avoid running billboard specific code
        if let nodeQuad, let material = nodeQuad.getSurfaceOverrideMaterial(surface: 0) as? BaseMaterial3D, material.billboardMode != .disabled {
            setProcess(enable: false)
        }
    }
    
    
    public override func _process(delta: Double) {
        // NOTE: Remove this function if you don't plan on using billboard settings.
        rotate_area_to_billboard()
    }
    
    func mouse_entered_area() {
        isMouseInside = true
    }
    
    
    func mouse_exited_area() {
        isMouseInside = false
    }
    
    public override func _unhandledInput(event: InputEvent?) {
        // Check if the event is a non-mouse/non-touch event
        
        // If the event is a mouse/touch event, then we can ignore it here, because it will be
        // handled via Physics Picking.
        switch event {
        case is InputEventMouseButton: 
            print("InputEventMouseButton")
            return
        case is InputEventMouseMotion: 
            print("InputEventMouseMotion")
            return
        case is InputEventScreenDrag: 
            print("InputEventScreenDrag")
            return
        case is InputEventScreenTouch: 
            print("InputEventScreenTouch")
            return
        default: nodeViewport?.pushInput(event: event)
        }
    }
    
    func mouse_input_event(camera: Node, event: InputEvent, eventPosition: Vector3, normal: Vector3, _shape_idx: Int64) {
        guard let nodeQuad, let mesh = nodeQuad.mesh as? PlaneMesh else {
            return
        }
        
        // Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
        let quadMeshSize = mesh.size
        
        // Event position in Area3D in world coordinate space.
        var eventPos3D = eventPosition
        
        // Current time in seconds since engine start.
        let now: Float = Float(Time.getTicksMsec()) / 1000.0
        
        // Convert position to a coordinate space relative to the Area3D node.
        // NOTE: affine_inverse accounts for the Area3D node's scale, rotation, and position in the scene!
        eventPos3D = nodeQuad.globalTransform.affineInverse() * eventPos3D
        
        // TODO: Adapt to bilboard mode or avoid completely.
        
        var eventPos2D = Vector2()
        
        if isMouseInside, let nodeViewport {
            // Convert the relative event position from 3D to 2D.
            eventPos2D = Vector2(x: eventPos3D.x, y: -eventPos3D.y)
            
            // Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
            // We need to convert it into the following range: -0.5 -> 0.5
            eventPos2D.x = eventPos2D.x / quadMeshSize.x
            eventPos2D.y = eventPos2D.y / quadMeshSize.y
            // Then we need to convert it into the following range: 0 -> 1
            eventPos2D.x += 0.5
            eventPos2D.y += 0.5
            
            // Finally, we convert the position to the following range: 0 -> viewport.size
            eventPos2D.x *= Float(nodeViewport.size.x)
            eventPos2D.y *= Float(nodeViewport.size.y)
            // We need to do these conversions so the event's position is in the viewport's coordinate system.
            
        } else if let lastEventPos2D {
            // Fall back to the last known event position.
            eventPos2D = lastEventPos2D
        }
        
        // Set the event's position and global position.
        if event is InputEventMouse {
            (event as! InputEventMouse).position = eventPos2D
            (event as! InputEventMouse).globalPosition = eventPos2D
        }
        
        // Calculate the relative event distance.
        if event is InputEventMouseMotion/* || event is InputEventScreenDrag*/ {
            // If there is not a stored previous position, then we'll assume there is no relative motion.
            if let lastEventPos2D {
                let relative = eventPos2D - lastEventPos2D
                (event as! InputEventMouseMotion).relative = relative
                
                (event as! InputEventMouseMotion).velocity =  Vector2(x: relative.x / (now - lastEventTime), y: relative.y / (now - lastEventTime))
            } else {
                (event as! InputEventMouseMotion).relative = Vector2(x: 0, y: 0)
                // If there is a stored previous position, then we'll calculate the relative position by subtracting
                // the previous position from the new position. This will give us the distance the event traveled from prev_pos.
            }
        }
        
        // Update lastEventPos2D with the position we just calculated.
        lastEventPos2D = eventPos2D
        
        // Update lastEventTime to current time.
        lastEventTime = now
        
        // Finally, send the processed input event to the viewport.
        nodeViewport?.pushInput(event: event)
    }
    
    func rotate_area_to_billboard() {
        guard let nodeQuad, let material = nodeQuad.getSurfaceOverrideMaterial(surface: 0) as? BaseMaterial3D else {
            return
        }
        
        let billboardMode = material.billboardMode
        
        // Try to match the area with the material's billboard setting, if enabled.
        guard billboardMode != .disabled, let camera = getViewport()?.getCamera3d(), let nodeArea else {
            return
        }
        
        // Look in the same direction as the camera.
        var look = camera.toGlobal(localPoint: Vector3(x: 0, y: 0, z: -100)) - camera.globalTransform.origin
        look = nodeArea.position + look
        
        // Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
        if billboardMode == .fixedY {
            look = Vector3(x: look.x, y: 0, z: look.z)
        }
        
        nodeArea.lookAt(target: look, up: .up)
        
        // Rotate in the Z axis to compensate camera tilt.
        nodeArea.rotateObjectLocal(axis: .back, angle: Double(camera.rotation.z))
    }
}

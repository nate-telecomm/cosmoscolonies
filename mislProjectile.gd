extends RigidBody3D

@export var TargetObject: Node
@export var thrust: float = 1.0

func _ready() -> void:
	if not TargetObject:
		print("No target object: ", TargetObject)
		queue_free()
	add_to_group("movable")

func _physics_process(delta: float) -> void:
	thrust += delta*10
	if not TargetObject or not is_instance_valid(TargetObject):
		queue_free()
		return

	look_at(TargetObject.global_transform.origin, Vector3.UP)

	var forward = -global_transform.basis.z
	apply_central_force(forward * thrust)

func _on_body_entered(body: Node) -> void:
	detonate()

func detonate():
	self.freeze = true
	$CPUParticles3D2.show()

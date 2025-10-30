extends RigidBody3D

@export var TargetObject: Node
@export var thrust: float = 1.0
@export var shake_radius: float = 15.0
@export var shake_intensity: float = 5000.0

func _ready() -> void:
	if not TargetObject:
		print("No target object: ", TargetObject)
		queue_free()
	add_to_group("movable")

func _physics_process(delta: float) -> void:
	thrust += delta * 10
	if not TargetObject or not is_instance_valid(TargetObject):
		queue_free()
		return

	look_at(TargetObject.global_transform.origin, Vector3.UP)
	var forward = -global_transform.basis.z
	apply_central_force(forward * thrust)

func detonate():
	self.freeze = true
	$CPUParticles3D.hide()
	$CollisionShape3D.hide()
	$CPUParticles3D2.show()
	$CPUParticles3D3.show()
	$CPUParticles3D2.emitting = true
	$CPUParticles3D3.emitting = true

	_trigger_screen_shake()

	await get_tree().create_timer(35).timeout
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == TargetObject:
		print("Misl Hit Target Object: ", TargetObject)
	else:
		print("Misl Hit: ", body)
	detonate()

func _trigger_screen_shake():
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node3D:
			var distance = global_position.distance_to(node.global_position)
			if distance <= shake_radius:
				Plne.ScreenShake(shake_intensity)
				print("Shake triggered for player within", distance, "m")

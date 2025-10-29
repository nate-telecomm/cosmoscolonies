extends RigidBody3D

@export var move_force: float = 20.0
@export var turn_speed: float = 5.0
@export var stop_distance: float = 1.0  # how close it needs to be to count as a hit

var TargetedObject: Node3D
var frozen: bool = false

func _ready() -> void:
	# enable collision notifications so body_entered will fire
	contact_monitor = true
	max_contacts_reported = 4

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if frozen or not (TargetedObject and is_instance_valid(TargetedObject)):
		return

	var dir_vec: Vector3 = TargetedObject.global_position - global_position
	var distance = dir_vec.length()

	# Stop if close enough
	if distance <= stop_distance:
		freeze()
		return

	var direction = dir_vec.normalized()

	# Smooth rotation toward target
	var target_basis = Basis().looking_at(direction, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_basis, turn_speed * state.step)

	# Apply movement force toward target
	var force = direction * move_force
	apply_central_force(force)


func _on_body_entered(body: Node) -> void:
	# Compare by instance — hit the intended target?
	if body == TargetedObject:
		freeze()


func freeze() -> void:
	# prevent further physics motion and interactions
	frozen = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = true

	# disable contact reporting and stop processing to ensure nothing else moves it
	contact_monitor = false
	set_physics_process(false)
	set_process(false)

	# optionally, disable collision by clearing collision layers/masks if you want it non-blocking:
	# collision_layer = 0
	# collision_mask = 0

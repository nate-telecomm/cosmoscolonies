extends SpringArm3D

@export var sensitivity: float = 2
@export var mouse_sensitivity: float = 0.005
@export var smoothing := 8.0
var target_rotation := Vector3.ZERO

func _ready() -> void:
	target_rotation = rotation

func _process(delta: float) -> void:
	if Input.is_action_pressed("pitch_plus"):
		target_rotation.x += sensitivity * delta
	if Input.is_action_pressed("yaw_plus"):
		target_rotation.y += sensitivity * delta
	if Input.is_action_pressed("pitch_minus"):
		target_rotation.x -= sensitivity * delta
	if Input.is_action_pressed("yaw_minus"):
		target_rotation.y -= sensitivity * delta

	rotation.x = lerp_angle(rotation.x, target_rotation.x, delta * smoothing)
	rotation.y = lerp_angle(rotation.y, target_rotation.y, delta * smoothing)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_rotation.x -= event.relative.y * mouse_sensitivity
		target_rotation.y -= event.relative.x * mouse_sensitivity

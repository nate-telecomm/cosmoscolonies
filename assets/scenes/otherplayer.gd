extends Node3D

var last_position: Vector3

func _ready() -> void:
	add_to_group("marker_target")

func _process(delta):
	if last_position != Vector3.ZERO:
		var direction = position - last_position
		if direction.length() > 0.01:
			look_at(position + direction, Vector3.UP)
	last_position = position

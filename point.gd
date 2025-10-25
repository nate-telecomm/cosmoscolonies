extends SubViewportContainer
var arrow: Area3D
var cam: Camera3D
var srect: SubViewportContainer
var player: CharacterBody3D
@export var object: Node3D

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	arrow = get_parent().get_node("SubViewportContainer/SubViewport/arrow")
	cam = get_viewport().get_camera_3d()
	srect = get_parent().get_node("SubViewportContainer")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		var nameof: String = await PopupService.prompt_input("Point picker", "Choose an object", "Object")
		object = get_tree().current_scene.get_node(nameof)
	if object != null:
		var target_pos: Vector3 = object.global_position
		var player_cam: Node3D
		if player.isFirst:
			player_cam = player.get_node("firstperson")
		else:
			player_cam = player.get_node("raycamera")
		
		# Project target position to screen space
		var screen_pos = cam.unproject_position(target_pos)
		
		# Get screen center
		var viewport_size = get_viewport().get_visible_rect().size
		var screen_center = viewport_size / 2
		
		# Calculate direction from center to target (in 2D screen space)
		var direction_2d = (screen_pos - screen_center).normalized()
		
		# Calculate angle for the arrow to point in that direction
		# atan2 gives angle in radians, pointing right is 0, going counter-clockwise
		var angle = atan2(direction_2d.y, direction_2d.x)
		
		# Rotate arrow to point in that direction
		# Adjust the angle offset based on your arrow's default orientation
		# If arrow points right by default, use angle directly
		# If arrow points up by default, subtract PI/2
		arrow.rotation.z = angle - PI/2  # Assuming arrow points up by default

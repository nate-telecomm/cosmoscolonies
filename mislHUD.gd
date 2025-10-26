extends Control

signal target_acquired(target_object)

@export var marker_scene: PackedScene = preload("uid://b680yv3burlwa")
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var tracked_objects: Array = []
var markers: Array = []

@export var look_at_scale_increase: float = 15.0
@export var look_at_angle_threshold: float = 5.0

@export var selected: Node

var base_sizes: Array = []

var progress_marker: Control = null
var progress_timer: float = 0.0
var progress_duration: float = 2.5
var original_size: Vector2
var target_object: Node

var is_progressing: bool = false

func _ready():
	await get_tree().process_frame

	tracked_objects = get_tree().get_nodes_in_group("marker_target")

	for obj in tracked_objects:
		var marker = marker_scene.instantiate()
		marker.visible = false
		add_child(marker)
		markers.append(marker)
		base_sizes.append(marker.size)

func _process(_delta):
	camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var showmarkers = Input.is_action_pressed("t")
	selected = null

	for i in range(tracked_objects.size()):
		var obj = tracked_objects[i]
		var marker = markers[i]
		marker.visible = showmarkers

		if not showmarkers:
			continue

		var pos_3d = obj.global_position + Vector3(0, 1.5, 0)
		if camera.is_position_behind(pos_3d):
			marker.visible = false
			continue

		var pos_2d = camera.unproject_position(pos_3d)
		marker.position = pos_2d - (marker.size / 2)

		var cam_forward = -camera.global_transform.basis.z
		var to_obj = (pos_3d - camera.global_transform.origin).normalized()
		var angle = rad_to_deg(acos(cam_forward.dot(to_obj)))

		var target_size = base_sizes[i]

		if angle < look_at_angle_threshold:
			target_size += Vector2(look_at_scale_increase, look_at_scale_increase)
			selected = marker
			target_object = obj

		marker.size = marker.size.lerp(target_size, 0.1)

	if selected and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if not is_progressing:
			progress_marker = marker_scene.instantiate()
			progress_marker.position = selected.position
			progress_marker.size = selected.size
			add_child(progress_marker)
			original_size = progress_marker.size
			progress_timer = 0.0
			is_progressing = true
		else:
			progress_timer += _delta
			var t = progress_timer / progress_duration
			var new_size = original_size.lerp(Vector2.ZERO, t)
			var delta_size = original_size - new_size
			progress_marker.position = selected.position + (delta_size / 2)
			progress_marker.size = new_size
	else:
		if is_progressing:
			if selected and progress_timer >= 0.0:
				emit_signal("target_acquired", target_object)
				print("Misl fired at object: ", target_object)
			if progress_marker:
				progress_marker.queue_free()
				progress_marker = null
			progress_timer = 0.0
			is_progressing = false


extends Control

signal target_acquired(target_object)

@export var marker_scene: PackedScene = preload("uid://b680yv3burlwa")
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var tracked_objects: Array = []
var markers: Array = []
var lockon_timer: float

var can_fire: bool = true
var fire_cooldown_timer: float = 0.0
var fire_cooldown_duration: float = 1.0

@export var look_at_scale_increase: float = 15.0
@export var look_at_angle_threshold: float = 5.0

@export var selected: Node

var base_sizes: Array = []

var progress_marker: Control = null
var progress_timer: float = 0.0
var progress_duration: float = 2.5
var original_size: Vector2
var target_object: Node
var progress_completed: bool

var previous_selection
var is_progressing: bool = false
var lock_sfx_player: AudioStreamPlayer = null

func _ready():
	await get_tree().process_frame
	tracked_objects = get_tree().get_nodes_in_group("marker_target")

	for obj in tracked_objects:
		var marker = marker_scene.instantiate()
		marker.visible = false
		add_child(marker)
		markers.append(marker)
		base_sizes.append(marker.size)

func _process(delta: float) -> void:
	if not can_fire:
		fire_cooldown_timer += delta
		if fire_cooldown_timer >= fire_cooldown_duration:
			can_fire = true
			fire_cooldown_timer = 0.0

	camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var showmarkers = Input.is_action_pressed("t") and not PopupService.IsPopup
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
			previous_selection = marker
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
			progress_completed = false
			is_progressing = true

			_start_lock_sound()
			lockon_timer = 0.0
		else:
			progress_timer += delta
			lockon_timer += delta

			var t = progress_timer / progress_duration
			var new_size = original_size.lerp(Vector2.ZERO, t)
			var delta_size = original_size - new_size
			progress_marker.position = selected.position + (delta_size / 2)
			progress_marker.size = new_size

			if progress_timer >= 2.25:
				if lockon_timer >= 0.08:
					Plne.PlaySFX("lockon", false)
					lockon_timer = 0.0

			if progress_timer >= progress_duration and not progress_completed:
				_stop_lock_sound()
				var label = selected.get_node_or_null("RichTextLabel")
				if label:
					label.visible = true
				progress_completed = true

	else:
		if is_progressing:
			_stop_lock_sound()
			if progress_marker:
				progress_marker.queue_free()
				progress_marker = null

			if previous_selection:
				var label = previous_selection.get_node_or_null("RichTextLabel")
				if label:
					label.visible = false

			if progress_completed and selected and can_fire:
				Plne.PlaySFX("fire")
				emit_signal("target_acquired", target_object)
				print("Missile fired at object: ", target_object)
				can_fire = false

			progress_timer = 0.0
			lockon_timer = 0.0
			progress_completed = false
			is_progressing = false

func _start_lock_sound():
	if lock_sfx_player and is_instance_valid(lock_sfx_player):
		return

	lock_sfx_player = AudioStreamPlayer.new()
	var stream = load("res://assets/audio/lock.ogg")

	if stream is AudioStreamOggVorbis:
		stream = stream.duplicate()
		stream.loop = true

	lock_sfx_player.stream = stream
	add_child(lock_sfx_player)
	lock_sfx_player.play()

func _stop_lock_sound():
	if lock_sfx_player and is_instance_valid(lock_sfx_player):
		lock_sfx_player.stop()
		lock_sfx_player.queue_free()
		lock_sfx_player = null

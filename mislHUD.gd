extends Control

@export var marker_scene: PackedScene = preload("res://mislHUD.tscn")
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var tracked_objects: Array = []

func _ready():
	# Objects that should have markers
	tracked_objects = get_tree().get_nodes_in_group("marker_target")
	for obj in tracked_objects:
		var marker = marker_scene.instantiate()
		marker.visible = false
		add_child(marker)

func _process(delta):
	if not camera:
		camera = get_viewport().get_camera_3d()
		if not camera:
			return

	var show = Input.is_action_pressed("t")

	for i in range(tracked_objects.size()):
		var obj = tracked_objects[i]
		if i >= get_child_count():
			return

		var marker = get_child(i)
		marker.visible = show

		if not show:
			continue

		var pos_3d = obj.global_position
		if camera.is_position_behind(pos_3d):
			marker.visible = false
			continue

		var pos_2d = camera.unproject_position(pos_3d)
		marker.position = pos_2d - marker.size / 2

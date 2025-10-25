extends Area3D

@export var PlanetName: String = ""
var _is_transitioning: bool = false

func _ready() -> void:
	PlanetName = get_parent().name
	print(PlanetName)

func _on_body_entered(body: Node3D) -> void:
	if _is_transitioning:
		return
	if not body.name == "Player":
		return
	_is_transitioning = true
	call_deferred("_change_scene", body)

func _change_scene(player: CharacterBody3D) -> void:
	var tree: SceneTree = get_tree()
	var old_scene: Node = tree.current_scene

	# Save player transform
	var saved_transform: Transform3D = player.global_transform

	# Remove player from current parent (if any)
	if player.get_parent():
		player.get_parent().remove_child(player)

	# Load the new scene
	var scene_path := "res://assets/planets/%s/main.tscn" % PlanetName
	var packed := ResourceLoader.load(scene_path)
	if packed == null or not packed is PackedScene:
		push_error("Failed to load planet scene: " + scene_path)
		if old_scene:
			old_scene.add_child(player)
		_is_transitioning = false
		return

	# Instantiate and add the new scene
	var new_scene: Node = packed.instantiate()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene

	# Wait a frame to make sure everything is ready
	await tree.process_frame

	# Place the player in the new scene
	var spawn = new_scene.get_node_or_null("Spawn")
	if spawn:
		spawn.add_child(player)
		player.global_transform = spawn.global_transform
	else:
		new_scene.add_child(player)
		player.global_transform = saved_transform
		player.velocity = Vector3.ZERO

	# Free old scene
	if old_scene and old_scene != new_scene:
		old_scene.queue_free()

	_is_transitioning = false

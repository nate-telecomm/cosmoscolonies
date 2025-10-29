extends Area3D

@export var PlanetName: String = ""
var _is_transitioning: bool = false

func _ready() -> void:
	PlanetName = get_parent().name
	
func _process(delta: float):
	#print(GlobalData.current_planet)
	pass

func _on_body_entered(body: Node3D) -> void:
	if _is_transitioning:
		return
	if not body.name == "Player":
		return
	_is_transitioning = true
	call_deferred("_change_scene", body)

func _change_scene(player: CharacterBody3D) -> void:
	if GlobalData.current_planet == "Space":
		player._origin_shift_enabled = false
		PopupService.popup("Entering " + PlanetName + "...")
		var tree: SceneTree = get_tree()
		var old_scene: Node = tree.current_scene

		var saved_transform: Transform3D = player.global_transform

		if player.get_parent():
			player.get_parent().remove_child(player)

		var scene_path := "res://assets/planets/%s/main.tscn" % PlanetName
		var packed := ResourceLoader.load(scene_path)
		if packed == null or not packed is PackedScene:
			push_error("Failed to load planet scene: " + scene_path)
			if old_scene:
				old_scene.add_child(player)
			_is_transitioning = false
			return

		var new_scene: Node = packed.instantiate()
		tree.root.add_child(new_scene)
		tree.current_scene = new_scene

		await tree.process_frame

		new_scene.add_child(player)
		player.position = Vector3(0, 5000, 0)
		player.velocity = Vector3.ZERO

		if old_scene and old_scene != new_scene:
			old_scene.queue_free()
		match PlanetName:
			"Umo":
				GlobalData.PlayLocalMusic("ph4se.vox")

		_is_transitioning = false
	else:
		var tree: SceneTree = get_tree()
		var old_scene: Node = tree.current_scene

		var saved_transform: Transform3D = player.global_transform

		if player.get_parent():
			player.get_parent().remove_child(player)

		var scene_path := "res://main.tscn"
		var packed := ResourceLoader.load(scene_path)
		if packed == null or not packed is PackedScene:
			push_error("Failed to load planet scene: " + scene_path)
			if old_scene:
				old_scene.add_child(player)
			_is_transitioning = false
			return

		var new_scene: Node = packed.instantiate()
		tree.root.add_child(new_scene)
		tree.current_scene = new_scene

		await tree.process_frame

		new_scene.add_child(player)
		player.position = Vector3(0, 5000, 0)
		player.velocity = Vector3.ZERO

		if old_scene and old_scene != new_scene:
			old_scene.queue_free()

		_is_transitioning = false
		#GlobalData.PlayLocalMusic("consumatesurvivor.caf")
		
		var pnode: StaticBody3D = get_tree().current_scene.get_node(PlanetName)
		var size: float = pnode.get_node("CollisionShape3D").shape.radius * 2
		var exit_offset = Vector3(pnode.position.x, pnode.position.y + size, pnode.position.z)
		player.position = exit_offset

		_is_transitioning = false
		player._origin_shift_enabled = true

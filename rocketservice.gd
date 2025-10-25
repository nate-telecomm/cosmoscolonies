extends Node
	
func get_part_height(part: Node3D) -> float:
	for child in part.get_children():
		if child is StaticBody3D:
			for sub in child.get_children():
				if sub is CollisionShape3D:
					var shape = sub.shape
					if shape is BoxShape3D:
						return shape.size.y
					elif shape is CapsuleShape3D:
						return shape.height + shape.radius * 2
					elif shape is SphereShape3D:
						return shape.radius * 2
	return 5
	
func _disable_part_collisions(node: Node) -> void:
	for child in node.get_children():
		if child is StaticBody3D:
			child.collision_layer = 0
			child.collision_mask = 0
			for sub in child.get_children():
				if sub is CollisionShape3D:
					sub.disabled = true
		elif child is CollisionShape3D:
			child.disabled = true
		else:
			_disable_part_collisions(child)

func build_rocket(json_string: String, parent_body: CharacterBody3D) -> Dictionary:
	var blueprint = JSON.parse_string(json_string)
	if blueprint == null or not blueprint.has("parts"):
		push_error("Invalid rocket blueprint!")
		return {}
	
	var rocket = Node3D.new()
	rocket.name = "Rocket"
	parent_body.add_child(rocket)
	rocket.rotation_degrees.x = -90
	
	var total_stats = {
		"fuel_capacity": 0,
		"thrust": 0,
		"mass": 0
	}
	
	var current_offset = Vector3(0, 0, 0)
	
	for part_data in blueprint["parts"]:
		var rname = part_data.get("name", "")
		var part_path = "res://assets/scenes/parts/%s.tscn" % rname
		if not ResourceLoader.exists(part_path):
			push_error("Part not found: %s" % rname)
			continue
		
		var part_scene = load(part_path)
		var part_instance = part_scene.instantiate()
		rocket.add_child(part_instance)
		_disable_part_collisions(part_instance)

		#var height = get_part_height(part_instance)
		part_instance.position = current_offset
		current_offset.y -= 5
		
		var stats_path = "res://assets/data/parts/%s.json" % rname
		if ResourceLoader.exists(stats_path):
			var stats_json = JSON.parse_string(FileAccess.get_file_as_string(stats_path))
			if stats_json:
				var stats = stats_json
				total_stats["fuel_capacity"] += stats.get("fuel_capacity", 0)
				total_stats["thrust"] += stats.get("thrust", 0)
				total_stats["mass"] += stats.get("mass", 0)
	
	return total_stats

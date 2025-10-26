extends Node3D

func _ready() -> void:
	GlobalData.init_connect()

	_register_movable_nodes(self)

func _register_movable_nodes(root: Node) -> void:
	for child in root.get_children():
		if child is StaticBody3D:
			if not child.is_in_group("movable"):
				child.add_to_group("movable")

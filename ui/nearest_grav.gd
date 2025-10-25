extends RichTextLabel

var planet: StaticBody3D
var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _process(delta: float) -> void:
	planet = GlobalData.get_nearest_gravity(player)
	if planet != null:
		text = "NEAREST: " + planet.name
	
	else:
		text = "NEAREST: SPACE"

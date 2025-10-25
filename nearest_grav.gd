extends RichTextLabel

var planet: StaticBody3D
var player: CharacterBody3D
var arrow: Area3D
var cam: Camera3D
var srect: SubViewportContainer

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _process(delta: float) -> void:
	planet = GlobalData.get_nearest_gravity(player)
	if planet != null:
		text = "NEAREST: " + planet.name
	
	else:
		text = "NEAREST: SPACE"

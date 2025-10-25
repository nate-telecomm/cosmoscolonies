extends RichTextLabel

var player: CharacterBody3D
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _process(delta: float) -> void:
	var speed_mps: float = GlobalData.get_character_speed(player)
	text = "SPEED: " + str(round(speed_mps)) + "m/s"

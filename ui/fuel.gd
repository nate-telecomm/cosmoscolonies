extends RichTextLabel

var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _process(delta: float) -> void:
	if player != null:
		text = "FUEL: " + str(player.RemainingFuel)

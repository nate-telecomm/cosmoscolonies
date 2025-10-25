extends ColorRect

var SVPC: SubViewportContainer
var L: LineEdit

func _ready() -> void:
	SVPC = get_parent().get_node("SubViewportContainer")
	L = get_node("LineEdit")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		visible = !visible

func _on_text_submitted(new_text: String) -> void:
	var text: String = L.text
	if L.text != "":
		GlobalData.PlayLocalSFX("sound2")
		var node: Node3D = get_tree().current_scene.get_node(text)
		if node != null:
			SVPC.object = node

extends RichTextLabel

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	text = "FPS: " + str(fps)

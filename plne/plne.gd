extends Node

var active_sfx: Dictionary = {}

func PlaySFX(sound: String, check: bool = true):
	var path = "res://assets/audio/" + sound + ".ogg"
	if active_sfx.has(path) and is_instance_valid(active_sfx[path]) and active_sfx[path].playing:
		return

	var stream = load(path)
	if not stream:
		push_warning("Sound not found: " + path)
		return

	var audioPlayer := AudioStreamPlayer.new()
	audioPlayer.stream = stream
	add_child(audioPlayer)
	if check:
		active_sfx[path] = audioPlayer
		audioPlayer.connect("finished", Callable(self, "_on_audio_finished").bind(path))
	else:
		audioPlayer.connect("finished", Callable(func():audioPlayer.queue_free()))

	audioPlayer.play()

func _on_audio_finished(path: String):
	if active_sfx.has(path):
		var audioPlayer = active_sfx.get(path)
		active_sfx.erase(path)
		if is_instance_valid(audioPlayer):
			audioPlayer.queue_free()

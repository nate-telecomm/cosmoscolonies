extends Node

var active_sfx: Dictionary = {}

@export var decay = 0.8
@export var max_offset = Vector3(0.5, 0.5, 0.5)
@export var max_roll = 0.1
@export var trauma_power = 2
@export var shake_lerp_speed = 10.0

var camera: Camera3D
var trauma = 0.0
var noise = FastNoiseLite.new()

var _original_pos: Vector3
var _original_rot: Vector3
var _current_shake_pos: Vector3 = Vector3.ZERO
var _current_shake_rot: Vector3 = Vector3.ZERO

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
		audioPlayer.finished.connect(_on_audio_finished.bind(path))
	else:
		audioPlayer.finished.connect(func(): audioPlayer.queue_free())

	audioPlayer.play()

func _on_audio_finished(path: String):
	if active_sfx.has(path):
		var audioPlayer = active_sfx.get(path)
		active_sfx.erase(path)
		if is_instance_valid(audioPlayer):
			audioPlayer.queue_free()

func ScreenShake(intensity: float, target_camera: Camera3D = null):
	if target_camera:
		camera = target_camera
		_original_pos = camera.position
		_original_rot = camera.rotation
	trauma = min(trauma + intensity, 1.0)

func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	camera = get_viewport().get_camera_3d()
	if camera:
		_original_pos = camera.position
		_original_rot = camera.rotation

func _process(delta):
	if not camera:
		return

	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake(delta)
	else:
		_current_shake_pos = _current_shake_pos.lerp(Vector3.ZERO, delta * shake_lerp_speed)
		_current_shake_rot = _current_shake_rot.lerp(Vector3.ZERO, delta * shake_lerp_speed)
		camera.position = _original_pos + _current_shake_pos
		camera.rotation = _original_rot + _current_shake_rot

func shake(delta):
	var amount = pow(trauma, trauma_power)
	var time = float(Time.get_ticks_msec()) / 1.0

	var target_offset = Vector3(
		noise.get_noise_2d(noise.seed, time) * max_offset.x * amount,
		noise.get_noise_2d(noise.seed + 100, time) * max_offset.y * amount,
		noise.get_noise_2d(noise.seed + 200, time) * max_offset.z * amount
	)

	var target_rot = Vector3(
		noise.get_noise_2d(noise.seed + 300, time) * max_roll * amount,
		noise.get_noise_2d(noise.seed + 400, time) * max_roll * amount,
		noise.get_noise_2d(noise.seed + 500, time) * max_roll * amount
	)

	_current_shake_pos = _current_shake_pos.lerp(target_offset, delta * shake_lerp_speed)
	_current_shake_rot = _current_shake_rot.lerp(target_rot, delta * shake_lerp_speed)

	camera.position = _original_pos + _current_shake_pos
	camera.rotation = _original_rot + _current_shake_rot

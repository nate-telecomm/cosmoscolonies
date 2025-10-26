extends CharacterBody3D

const ROT_SPEED: float = 2.0
var AIR_DRAG: float
var camera1: Camera3D
var camera2: Camera3D
@onready var Marker: TextureRect = $CanvasLayer/TextureRect
var object: Node3D
@export var isFirst: bool
@export var gravity_strength: float = 8
var MessageBox: TextEdit
var EnterBox: LineEdit
var SendButton: RichTextLabel
var RocketStats: Dictionary
@export var RocketJSON: String

var SPEED: float = 100.0
var ACCEL: float = 6000.0
@export var RemainingFuel: float = 0.0

func _text_submitted():
	if EnterBox.text != "":
		GlobalData.send_chat_message(EnterBox.text)
		EnterBox.text = ""
		
func isInRocket() -> bool:
	
	return get_node_or_null("Rocket") != null
func _rocket_Engine() -> StaticBody3D:
	return get_node("Rocket").get_node("Engine")

func _ready() -> void:
	camera1 = $firstperson
	camera2 = $raycamera/thirdperson

func _physics_process(delta: float) -> void:
	if isInRocket() and _rocket_Engine() != null:
		_rocket_Engine().get_node("Fire").emitting = false
	if isFirst:
		camera1.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		camera2.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !PopupService.IsPopup:
		if Input.is_action_pressed("zoom"):
			camera1.fov = 1
		else:
			camera1.fov = 70
		var input_dir: Vector3 = Vector3.ZERO
		if Input.is_action_pressed("throttle"):
			if RemainingFuel > 0.0:
				input_dir -= transform.basis.z
				if isInRocket() and _rocket_Engine() != null:
					_rocket_Engine().get_node("Fire").emitting = true
				RemainingFuel -= SPEED/10000
		var yaw_input: float = 0.0
		var pitch_input: float = 0.0
		var qe_input: float = 0.0

		if Input.is_action_pressed("q"):
			qe_input += 1.0
		if Input.is_action_pressed("e"):
			qe_input -= 1.0
		if Input.is_action_pressed("left"):
			yaw_input += 1.0
		if Input.is_action_pressed("right"):
			yaw_input -= 1.0
		if Input.is_action_pressed("backward"):
			pitch_input += 1.0
		if Input.is_action_pressed("forward"):
			pitch_input -= 1.0
		if pitch_input != 0.0:
			transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * ROT_SPEED * delta)
		if yaw_input != 0.0:
			transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * ROT_SPEED * delta)
		if qe_input != 0.0:
			transform.basis = transform.basis.rotated(transform.basis.z, qe_input * ROT_SPEED * delta)

		var desired_velocity = Vector3.ZERO
		if input_dir.length_squared() > 0.0001:
			desired_velocity = input_dir.normalized() * SPEED
			velocity = velocity.move_toward(desired_velocity, ACCEL * delta)

		if get_tree().current_scene.name != "Space":
			velocity.y -= gravity_strength * delta
		else:
			pass

		move_and_slide() 

		if Input.is_action_just_pressed("camera"):
			isFirst = !isFirst

		if Input.is_action_just_pressed("menu"):
			var obj: String = await PopupService.prompt_input("", "Enter object")
			if obj != "%%NULL%%":
				if obj.begins_with("player:"):
					for player_node in GlobalData.other_players:
						if GlobalData.other_players[player_node].name == obj.trim_prefix("player:"):
							object = GlobalData.other_players[player_node]
				else:
					object = get_tree().current_scene.get_node(obj)
			else:
				object = null

		var camera := get_viewport().get_camera_3d()
		if object == null or camera.is_position_behind(object.global_transform.origin):
			Marker.visible = false
		else:
			Marker.visible = true
			var screen_pos: Vector2 = camera.unproject_position(object.global_transform.origin)
			Marker.position = screen_pos

		if Input.is_action_just_pressed("menu2"):
			var json: String = await PopupService.prompt_input("", "Enter rocket JSON")
			if json != "%%NULL%%":
				RocketJSON = json
				RocketStats = RocketService.build_rocket(RocketJSON, self)
				SPEED = RocketStats["thrust"]/2
				ACCEL = RocketStats["accel"]/2
				RemainingFuel = RocketStats["fuel_capacity"]

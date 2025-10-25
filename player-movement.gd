extends CharacterBody3D

var SPEED: float = 200000.0
var ACCEL: float = 6000.0
const ROT_SPEED: float = 2.0
var AIR_DRAG: float
var camera1: Camera3D
var camera2: Camera3D
var Marker: MeshInstance3D
@export var isFirst: bool
@export var gravity_strength: float = 8

func _ready() -> void:
	camera1 = $firstperson
	camera2 = $raycamera/thirdperson

func _physics_process(delta: float) -> void:
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
			input_dir -= transform.basis.z
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
			print(obj)
			if obj != "%%NULL%%":
				var object: Node3D = get_tree().current_scene.get_node(obj)
				mark(object)

func mark(object: Node3D) -> void:
	if Marker != null:
		Marker.queue_free()
		Marker = null
	var mesh: PlaneMesh
	mesh = PlaneMesh.new()
	mesh.size = Vector2i(30000, 30000)
	mesh.material = load("res://assets/materials/marker.tres")
	mesh.orientation = PlaneMesh.FACE_Z
	Marker = MeshInstance3D.new()
	Marker.mesh = mesh
	object.add_child(Marker)

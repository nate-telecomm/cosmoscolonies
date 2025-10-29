extends GPUParticles3D

@export var slow_duration := 2.0  
@export var min_speed := 0.1      
@export var max_speed := 1.0      
var slowing_down := false
var elapsed := 0.0

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	slowing_down = true

func _process(delta: float) -> void:
	if slowing_down:
		elapsed += delta
		var t = clamp(elapsed / slow_duration, 0.0, 1.0)
		speed_scale = lerp(max_speed, min_speed, t)
		if t >= 1.0:
			slowing_down = false

extends Node3D

var json: String = ""
@onready var jsonInput: CodeEdit = $CodeEdit
@onready var PlaceAt: Node3D = $Node3D

func _ready() -> void:
	pass 
	
func _process(delta: float) -> void:
	RocketService.build_rocket(json, PlaceAt)


func _on_code_edit_text_changed() -> void:
	json = jsonInput.text

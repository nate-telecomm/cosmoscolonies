extends Node

var Player: CharacterBody3D
var UI: Control
var diag: AcceptDialog
var LE: LineEdit
var IsPopup: bool = false

var _lastInput: String = ""

func _cancelled():
	IsPopup = false
	_lastInput = "%%NULL%%"
	
func _accepted():
	_lastInput = LE.text
	IsPopup = false
	diag.queue_free()

func prompt_input(title: String, body: String, default_text: String = "") -> String:
	IsPopup = true
	Player = get_tree().current_scene.get_node("Player")
	UI = Player.get_node("ui")
	Player.isFirst = true
	
	
	diag = AcceptDialog.new()
	diag.theme = load("res://assets/maintheme.tres")
	diag.visible = true
	diag.size = Vector2i(300, 300)
	diag.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	diag.unresizable = true
	diag.borderless = true
	diag.add_cancel_button("Cancel")
	diag.canceled.connect(_cancelled)
	diag.confirmed.connect(_accepted)
	UI.add_child(diag)
	
	var L: RichTextLabel = RichTextLabel.new()
	L.text = body
	diag.add_child(L)
	
	LE = LineEdit.new()
	diag.add_child(LE)
	
	while _lastInput == "":
		await get_tree().process_frame
		
	GlobalData.PlayLocalSFX("sound2")

	var inp: String = _lastInput
	_lastInput = ""
	return inp

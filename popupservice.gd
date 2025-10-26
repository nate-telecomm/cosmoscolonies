extends Node

var Player: CharacterBody3D
var UI: Control
var diag: AcceptDialog
var LE: CodeEdit
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
	var wasThird: bool = !Player.isFirst
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
	
	LE = CodeEdit.new()
	diag.add_child(LE)
	
	while _lastInput == "":
		await get_tree().process_frame
		
	GlobalData.PlayLocalSFX("sound2")

	var inp: String = _lastInput
	_lastInput = ""
	if wasThird:
		Player.isFirst = false
	return inp

func popup(text: String) -> void:
	var player = get_tree().current_scene.get_node("Player")
	var ui = player.get_node("ui")

	var label := Label.new()
	label.theme = load("res://assets/maintheme.tres")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(label)
	var viewport_size = get_viewport().get_visible_rect().size

	for i in text.length():
		label.text += text.substr(i, 1)
		var node_size = label.size
		label.position = (viewport_size - node_size) / 2
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(3).timeout

	while label.text.length() > 0:
		label.text = label.text.substr(0, label.text.length() - 1)
		var node_size = label.size
		label.position = (viewport_size - node_size) / 2
		await get_tree().create_timer(0.03).timeout

	label.queue_free()

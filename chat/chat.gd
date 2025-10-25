extends Control

@onready var chat_player_name: RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/PlayerName
@onready var chat_messages: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Messages
@onready var chat_messager: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Messager

var finished: String

func _ready() -> void:
	chat_player_name.text = GlobalData.username

func _on_messager_text_submitted(new_text: String) -> void:
	GlobalData.send_chat_message(new_text)
	chat_messager.text = ""

func _process(_delta: float) -> void:
	for chat in GlobalData.chat_messages:
		finished += "[%s]: %s" % [chat["user"], chat["msg"]] + "\n"
	chat_messages.text = finished
	await get_tree().create_timer(5).timeout

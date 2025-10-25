extends Control

@onready var chat_player_name: RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/PlayerName
@onready var chat_messages: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Messages
@onready var chat_messager: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Messager

var last_message_count := 0

func _ready() -> void:
	chat_player_name.text = GlobalData.username
	chat_messages.editable = false

func _on_messager_text_submitted(new_text: String) -> void:
	GlobalData.send_chat_message(new_text)
	chat_messager.text = ""

func _process(_delta: float) -> void:
	if GlobalData.chat_messages.size() != last_message_count:
		update_chat_display()
		last_message_count = GlobalData.chat_messages.size()

func update_chat_display() -> void:
	var text := ""
	for chat in GlobalData.chat_messages:
		text += "[%s]: %s\n" % [chat["user"], chat["msg"]]
	
	chat_messages.text = text
	
	chat_messages.scroll_vertical = chat_messages.get_v_scroll_bar().max_value

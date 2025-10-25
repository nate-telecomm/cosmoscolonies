extends Control

@onready var chat_player_name: RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/PlayerName
@onready var chat_messages: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Messages
@onready var chat_messager: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Messager

func _ready() -> void:
	#chat_player_name = <username> 
	## Idfk how the network code works so someones gotta get the username on the chat_player_name variable
	pass

func _on_messager_text_submitted(new_text: String) -> void:
	## This is where network code is need to send the message to the server
	pass

func _on_message(username: String, text: String):
	chat_messages.text += str(username + ": " + text)
	## gotta somehow get this to update across all clients 

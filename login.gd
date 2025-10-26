extends Control

@export var websocket_url = "ws://home.ununhexium.net:53920/game"
@onready var user = $VBoxContainer/HBoxContainer/username
@onready var passw = $VBoxContainer/HBoxContainer/password
@onready var login = $VBoxContainer/Button
@onready var status = $VBoxContainer/status
@onready var music = $AudioStreamPlayer
@onready var address: LineEdit = $VBoxContainer/address

var video: VideoStreamPlayer

var socket = WebSocketPeer.new()
const sep = "$%^%^%^&*((&W^))"

func _ready() -> void:
	video = get_node("VideoStreamPlayer")
	video.size = get_viewport_rect().size
	address.text = "home.ununhexium.net"

var connected = false
var authenticated = false
var waiting_for_credentials = false

func _on_button_button_down() -> void:
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		status.text = "Unable to connect\n" + str(err)
		return

	connected = true
	status.text = "Connecting..."

func _process(_delta):
	if connected:
		socket.poll()
		var state = socket.get_ready_state()
		
		if state == WebSocketPeer.STATE_OPEN:
			if not waiting_for_credentials and not authenticated:
				socket.send_text("chk_usr")
				waiting_for_credentials = true
				status.text = "Checking credentials..."
			
			while socket.get_available_packet_count() > 0:
				var packet = socket.get_packet().get_string_from_utf8()
				print("Received: ", packet)
				
				if packet == "y" and waiting_for_credentials:
					socket.send_text(user.text + sep + passw.text)
					status.text = "Sending credentials..."
				
				elif packet == "!y":
					authenticated = true
					status.text = "Login successful!"
					GlobalData.username = user.text
					GlobalData.password = passw.text
					get_tree().change_scene_to_file("res://main.tscn")
				
				elif packet == "!n":
					status.text = "Invalid username or password"
					socket.close()
					connected = false
					waiting_for_credentials = false
		
		elif state == WebSocketPeer.STATE_CLOSED:
			status.text = "Connection closed"
			connected = false


func _on_video_stream_player_finished() -> void:
	video.visible = false

func _on_address_text_changed(new_text: String) -> void:
	websocket_url = "ws://" + new_text + ":53920/game"

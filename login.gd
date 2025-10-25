extends Node2D

@export var websocket_url = "ws://home.ununhexium.net:53920/game"
@onready var user = $username
@onready var passw = $password
@onready var login = $Button
@onready var status = $status
@onready var music = $AudioStreamPlayer
var socket = WebSocketPeer.new()
const sep = "$%^%^%^&*((&W^))"

func _ready() -> void:
	music.play()

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

func _process(delta):
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

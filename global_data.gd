extends Node3D

var username: String
var password: String
var maindelta: float
var chat_messages: Array = []
var lerp_speed: float = 8.0
var current_planet: String

func array_to_string(arr: Array) -> String:
	var result_string = ""
	for element in arr:
		result_string += str(element)
	return result_string

func send_chat_message(text: String) -> void:
	if authenticated:
		socket.send_text("scm " + text)
		
func request_chat_messages() -> void:
	if authenticated:
		socket.send_text("gcm")

func get_nearest(group_name: String, max_distance: float, player: CharacterBody3D) -> Node3D:
	var nodes = get_tree().get_nodes_in_group(group_name)
	var closest_object: StaticBody3D = null
	var min_distance_sq: float = INF

	var max_distance_sq: float = max_distance * max_distance

	for object in nodes:
		if not object is StaticBody3D:
			continue
		
		var distance_sq: float = player.global_position.distance_squared_to(object.global_position)
		
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_object = object

	if closest_object != null and min_distance_sq <= max_distance_sq:
		return closest_object
	else:
		return null

func get_nearest_gravity(player: CharacterBody3D) -> Node3D:
	var max_surface_distance: float = 3000000.0
	var done: Node3D = get_nearest("celestialbodies", max_surface_distance, player)
	if done != null:
		return done
	var nodes = get_tree().get_nodes_in_group("Gravity_sources") # Max distance from the surface
	
	var closest_gravity_source: Node3D = null
	var min_surface_distance: float = INF

	for gravity_source in nodes:
		if not gravity_source is Node3D:
			continue

		var radius: float = 0.0
		if gravity_source.has_method("get_radius"):
			radius = gravity_source.get_radius()
		elif gravity_source.has_node("CollisionShape3D"):
			if gravity_source.has_meta("gravity_radius"):
				radius = gravity_source.get_meta("gravity_radius")
			elif gravity_source.has_node("MeshInstance3D"):
				pass # Skip if radius is 0.0
			else:
				continue
		else:
			continue
		var center_to_center_distance: float = player.global_position.distance_to(gravity_source.global_position)
		
		var surface_distance: float = center_to_center_distance - radius
		
		if surface_distance < min_surface_distance:
			min_surface_distance = surface_distance
			closest_gravity_source = gravity_source

	if closest_gravity_source != null and min_surface_distance <= max_surface_distance:
		return closest_gravity_source
	else:
		return null
		
func get_character_speed(object: CharacterBody3D) -> float:
	if object == null:
		return 0
	return object.velocity.length()
func change_websocket_address(address: String):
	websocket_url = address

@export var websocket_url = "ws://home.ununhexium.net:53920/game"
@export var other_player_scene: PackedScene = load("res://assets/scenes/player.tscn")
var socket = WebSocketPeer.new()
const sep = "$%^%^%^&*((&W^))"

var connected: bool = false
var waiting_for_credentials: bool = false
var authenticated: bool = false

var other_players: Dictionary = {}

func init_connect() -> void:
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		return

	connected = true

func _process(delta):
	current_planet = get_tree().current_scene.name
	maindelta = delta
	if connected:
		var player = get_tree().current_scene.get_node_or_null("Player")
		socket.poll()
		var state = socket.get_ready_state()
		
		if state == WebSocketPeer.STATE_OPEN:
			if not waiting_for_credentials and not authenticated:
				socket.send_text("login")
				waiting_for_credentials = true
			
			request_chat_messages()
			while socket.get_available_packet_count() > 0:
				var packet = socket.get_packet().get_string_from_utf8()

				if packet == "y" and waiting_for_credentials:
					socket.send_text(GlobalData.username + sep + GlobalData.password)
				elif packet == "!y":
					authenticated = true
				elif packet == "!n":
					socket.close()
					connected = false
					waiting_for_credentials = false
				elif packet.begins_with("{"):
					var json = JSON.new()
					if json.parse(packet) == OK:
						var data = json.data
						if data.has("pos"):
							update_other_players(data["pos"])
						elif data.has("chat"):
							update_chat(data["chat"])

			if authenticated:
				if player:
					socket.send_text("pos " + 
						str(player.position.x) + " " + 
						str(player.position.y) + " " +
						str(player.position.z) + " " +
						
						str(player.rotation.x) + " " +
						str(player.rotation.y) + " " +
						str(player.rotation.z) + " " +
						get_tree().current_scene.name + " " +
						player.RocketJSON)
					socket.send_text("gpl")
					
		elif state == WebSocketPeer.STATE_CLOSED:
			connected = false
			
func update_chat(chat_data: Array) -> void:
	chat_messages = chat_data

func update_other_players(players_data):
	var now = Time.get_unix_time_from_system()
	var current_players = {}
	var planets = {}
	
	for player_info in players_data:
		var username = str(player_info.get("username", "unknown"))
		
		if player_info["x"] == null:
			player_info["x"] = 0
		if player_info["y"] == null:
			player_info["y"] = 0
		if player_info["z"] == null:
			player_info["z"] = 0
		if player_info["xr"] == null:
			player_info["xr"] = 0
		if player_info["yr"] == null:
			player_info["yr"] = 0
		if player_info["zr"] == null:
			player_info["zr"] = 0
		if player_info["planet"] == null:
			player_info["planet"] = "Space"
		if player_info["rocketjson"] == null:
			player_info["rocketjson"] = "{}"
		
		var x = float(player_info.get("x", 0))
		var y = float(player_info.get("y", 0))
		var z = float(player_info.get("z", 0))
		var xr = float(player_info.get("xr", 0))
		var yr = float(player_info.get("yr", 0))
		var zr = float(player_info.get("zr", 0))
		var planet = str(player_info.get("planet", "Space"))
		
		var pos = Vector3(x, y, z)
		var rot = Vector3(xr, yr, zr)
		current_players[username] = true
		planets[username] = planet

		if not other_players.has(username) and planets[username] == current_planet:
			var root = get_tree().current_scene
			var player_node = other_player_scene.instantiate()
			player_node.name = username
			root.add_child(player_node)
			other_players[username] = {"node": player_node, "last_seen": now, "json": player_info["rocketjson"]}
			RocketService.build_rocket(other_players[username]["json"], player_node)

			if player_node.has_node("Label3D"):
				player_node.get_node("Label3D").text = username
				
		if other_players.has(username):
			other_players[username]["last_seen"] = now
			var player_node = other_players[username]["node"]
			if other_players[username]["json"] != player_info["rocketjson"]:
				other_players[username]["json"] = player_info["rocketjson"]
				RocketService.build_rocket(other_players[username]["json"], player_node)
			
			player_node.global_transform.origin = player_node.global_transform.origin.lerp(pos, lerp_speed * maindelta)
			player_node.rotation = rot
			
	var keys = other_players.keys()
	for username in keys:
		var last = other_players[username]["last_seen"]
		var node_ref = other_players[username]["node"]

		if now - last > 1.8:
			node_ref.queue_free()
			other_players.erase(username)
			planets.erase(username)
		else:
			if planets.has(username) and planets[username] != current_planet:
				node_ref.queue_free()
				other_players.erase(username)
				planets.erase(username)

func PlayLocalSFX(option: String) -> void:
	var sfx: AudioStreamPlayer = get_tree().current_scene.get_node("Player").get_node("LocalSFX")
	if sfx:
		sfx.stop()
	var stream: AudioStream
	stream = load("res://assets/audio/" + option + ".ogg")
	if sfx:
		sfx.stream = stream
		sfx.play()
	print(stream)

func PlayLocalMusic(track: String) -> void:
	"""
	var sfx: AudioStreamPlayer = get_tree().current_scene.get_node("Player").get_node("Music")
	if sfx:
		sfx.stop()
	var stream: AudioStream
	stream = load("res://assets/music/" + track + ".mp3")
	if sfx:
		sfx.stream = stream
		sfx.play()
	print(stream)
	"""

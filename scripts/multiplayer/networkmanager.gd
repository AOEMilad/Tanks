extends Node

@export var player_tank_scene: PackedScene = preload("res://scenes/game_objects/tanks/player_tank.tscn")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	####### For testing only – later replace with UI
	var is_host = true  # ← Change to false on second instance
	if is_host:
		host_game()
	else:
		join_game("192.168.1.64")  # Replace with host's IP address
	######

func _on_connected_to_server():
	print("Connected to server. Requesting player spawn.")
	# Client requests server to spawn their player
	request_spawn.rpc_id(1, multiplayer.get_unique_id())

# Host game on specified port
func host_game(port := 12345):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("Failed to create server: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("Hosting on port ", port)
	
	# Host should spawn their own player after a short delay
	# This ensures the server is fully set up first
	await get_tree().create_timer(0.5).timeout
	spawn_player(multiplayer.get_unique_id())

# Join existing game
func join_game(address: String, port := 12345):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("Failed to connect: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("Joining ", address + ":" + str(port))

# Called when a new peer connects
func _on_peer_connected(id: int) -> void:
	print("Peer connected:", id)
	# We don't spawn automatically here anymore
	# We'll wait for the client to request it

# Called when a peer disconnects
func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected:", id)
	# Remove the player's tank if it exists
	var player_node = get_tree().get_root().find_child(str(id), true, false)
	if player_node:
		player_node.queue_free()

# Client calls this to request spawning their player from the server
@rpc("any_peer", "call_remote", "reliable")
func request_spawn(id: int):
	# Only the server should handle spawn requests
	if not multiplayer.is_server():
		return
	
	print("Received spawn request from: ", id)
	spawn_player(id)

# This spawns a player tank and assigns ownership
func spawn_player(peer_id: int):
	print("Spawning player for peer: ", peer_id)
	var tank = player_tank_scene.instantiate()
	
	# Set a unique name based on the peer ID to make it easier to find later
	tank.name = str(peer_id)
	
	# Set the proper multiplayer authority
	tank.set_multiplayer_authority(peer_id)
	
	# Add to the world
	get_tree().get_root().add_child(tank)
	
	# Position the tank (staggered to avoid overlap)
	tank.global_position = Vector2(200 + 150 * (peer_id % 4), 400 + 150 * (peer_id / 4))

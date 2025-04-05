extends Node

@export var player_tank_scene: PackedScene = preload("res://scenes/game_objects/tanks/player_tank.tscn")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	####### For testing only – later replace with UI
	var is_host = true  # ← Change to false on second instance

	if is_host:
		host_game()
	else:
		join_game("192.168.1.64")  # Replace with public IP for real friend
	######
	
	if multiplayer.is_server():
		print("Server running with ID:", multiplayer.get_unique_id())

# Call this from UI or test it in _ready() for now
func host_game(port := 12345):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("Hosting on port", port)
	spawn_player(multiplayer.get_unique_id())

func join_game(address: String, port := 12345):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	print("Joining", address + ":" + str(port))

# Called when a new peer joins the server
func _on_peer_connected(id: int) -> void:
	print("Peer connected:", id)
	spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected:", id)

# This spawns a player tank and assigns ownership
func spawn_player(peer_id: int):
	var tank = player_tank_scene.instantiate()
	tank.set_multiplayer_authority(peer_id)
	get_tree().get_root().add_child(tank)
	tank.global_position = Vector2(200 + 300 * peer_id, 400)  # Stagger players apart

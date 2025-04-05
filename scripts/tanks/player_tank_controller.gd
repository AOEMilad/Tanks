extends TankController
class_name PlayerTankController

@export var player_index: int = 0  # For multiple local players

func _ready():
	super._ready()
	
	# Print debugging info to help troubleshoot
	print("Player tank initialized with authority:", get_multiplayer_authority())
	print("Local player ID:", multiplayer.get_unique_id())
	print("Is authority match:", is_multiplayer_authority())

func update_cannon_aim():
	if !is_multiplayer_authority():
		return
		
	var mouse_pos = get_global_mouse_position()
	var cannon_global_pos = cannon.global_position
	var aim_direction = (mouse_pos - cannon_global_pos).normalized()
	cannon.global_rotation = aim_direction.angle()
	
	# Sync the cannon rotation to all clients
	sync_cannon_rotation.rpc(cannon.global_rotation)

@rpc("authority", "call_remote", "unreliable")
func sync_cannon_rotation(rotation_value: float):
	if !is_multiplayer_authority():
		cannon.global_rotation = rotation_value

func get_movement_input() -> Vector2:
	if !is_multiplayer_authority():
		return Vector2.ZERO
		
	var input_vector = Vector2.ZERO
	if player_index == 0:
		if Input.is_action_pressed("p1_move_forward"):
			input_vector.y = -1
		elif Input.is_action_pressed("p1_move_backward"):
			input_vector.y = 1
	else:
		if Input.is_action_pressed("p2_move_forward"):
			input_vector.y = -1
		elif Input.is_action_pressed("p2_move_backward"):
			input_vector.y = 1
	return input_vector

func get_rotation_input() -> float:
	if !is_multiplayer_authority():
		return 0.0
		
	var rotation_input = 0.0
	if player_index == 0:
		if Input.is_action_pressed("p1_rotate_left"):
			rotation_input = -1.0
		elif Input.is_action_pressed("p1_rotate_right"):
			rotation_input = 1.0
	else:
		if Input.is_action_pressed("p2_rotate_left"):
			rotation_input = -1.0
		elif Input.is_action_pressed("p2_rotate_right"):
			rotation_input = 1.0
	return rotation_input

func _input(event):
	if !is_multiplayer_authority():
		return
		
	if player_index == 0 and event.is_action_pressed("p1_shoot"):
		shoot()
	elif player_index == 1 and event.is_action_pressed("p2_shoot"):
		shoot()

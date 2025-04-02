# res://scripts/tanks/player_tank_controller.gd
extends TankController

class_name PlayerTankController

# Control settings
@export var player_index: int = 0  # For multiple local players

func _ready():
	super._ready()

# Override to get player-specific input
func get_movement_input() -> Vector2:
	var input_vector = Vector2.ZERO
	
	# Different input handling for player 1 and 2
	if player_index == 0:
		# WASD controls for player 1
		if Input.is_action_pressed("p1_move_forward"):
			input_vector.y = -1
		elif Input.is_action_pressed("p1_move_backward"):
			input_vector.y = 1
	else:
		# Arrow keys for player 2
		if Input.is_action_pressed("p2_move_forward"):
			input_vector.y = -1
		elif Input.is_action_pressed("p2_move_backward"):
			input_vector.y = 1
	
	# Convert local input to global direction
	return input_vector.rotated(rotation)

# Override to get player-specific rotation input
func get_rotation_input() -> float:
	var rotation_input = 0.0
	
	if player_index == 0:
		# A/D keys for rotation
		if Input.is_action_pressed("p1_rotate_left"):
			rotation_input = -1.0
		elif Input.is_action_pressed("p1_rotate_right"):
			rotation_input = 1.0
	else:
		# Left/Right arrows for rotation
		if Input.is_action_pressed("p2_rotate_left"):
			rotation_input = -1.0
		elif Input.is_action_pressed("p2_rotate_right"):
			rotation_input = 1.0
			
	return rotation_input

func _input(event):
	# Handle shooting
	if player_index == 0 and event.is_action_pressed("p1_shoot"):
		shoot()
	elif player_index == 1 and event.is_action_pressed("p2_shoot"):
		shoot()

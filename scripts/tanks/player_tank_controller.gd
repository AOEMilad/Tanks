extends TankController

class_name PlayerTankController

@export var player_index: int = 0  # For multiple local players

func _ready():
	super._ready()
	
func update_cannon_aim():
	var mouse_pos = get_global_mouse_position()
	var cannon_global_pos = cannon.global_position
	var aim_direction = (mouse_pos - cannon_global_pos).normalized()
	cannon.global_rotation = aim_direction.angle()

func get_movement_input() -> Vector2:
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

	return input_vector.rotated(rotation)  # Ensure movement aligns with rotation

func get_rotation_input() -> float:
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
	if player_index == 0 and event.is_action_pressed("p1_shoot"):
		shoot()
	elif player_index == 1 and event.is_action_pressed("p2_shoot"):
		shoot()

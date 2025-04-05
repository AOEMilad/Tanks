extends CharacterBody2D

class_name TankController

# Tank movement
@export var max_speed: float = 150.0
@export var acceleration: float = 500.0
@export var friction: float = 700.0
@export var rotation_speed: float = 1.2

# Shooting
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.2
@export var max_projectiles: int = 4
@export var reload_time: float = 2.0

# AI & Player Control
@export var is_player: bool = false  # True for player tanks, False for AI tanks

# Sounds
@onready var shoot_sound = $ShootSound

# State
var can_fire: bool = true
var shots_fired: int = 0
var is_reloading: bool = false
var can_move: bool = true

# Components
@onready var cannon = $Cannon
@onready var cannon_sprite = $Cannon/CannonSprite
@onready var projectile_spawn = $Cannon/ProjectileSpawn
@onready var cooldown_timer = $CooldownTimer
@onready var reload_timer = $ReloadTimer

func _ready():
	cooldown_timer.wait_time = fire_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_timer_timeout)

func _physics_process(delta):
	handle_movement(delta)
	handle_rotation(delta)
	update_cannon_aim()
	move_and_slide()

func handle_movement(delta):
	if !can_move:
		return

	var input_vector = get_movement_input().normalized()

	if input_vector != Vector2.ZERO:
		# Forward direction is the tank's current facing direction
		var forward = Vector2.UP.rotated(rotation)

		# Determine if input is aligned with forward (positive) or backward (negative)
		var direction_sign = sign(forward.dot(input_vector))

		# Move in the current rotation direction * forward or backward
		var move_direction = forward * direction_sign
		velocity = velocity.move_toward(move_direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func handle_rotation(delta):
	if !can_move:
		return

	var dir = get_rotation_input()
	rotation += dir * rotation_speed * delta

# Cannon aiming logic
func update_cannon_aim():
	if is_player:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - cannon.global_position).normalized()
		cannon.rotation = direction.angle()
	else:
		# AI targets the nearest player tank
		var player_tank = get_nearest_player_tank()
		if player_tank:
			var direction = (player_tank.global_position - cannon.global_position).normalized()
			cannon.rotation = direction.angle()

# Finds the nearest player-controlled tank for AI targeting
func get_nearest_player_tank() -> Node2D:
	var player_tanks = get_tree().get_nodes_in_group("player_tanks")
	if player_tanks.is_empty():
		return null

	var closest_tank = player_tanks[0]
	var min_distance = global_position.distance_to(closest_tank.global_position)

	for tank in player_tanks:
		var distance = global_position.distance_to(tank.global_position)
		if distance < min_distance:
			closest_tank = tank
			min_distance = distance

	return closest_tank

func get_movement_input() -> Vector2:
	return Vector2.ZERO  # Implement actual player input handling

func get_rotation_input() -> float:
	return 0.0  # Implement actual player input handling

# Shooting logic
func shoot():
	if !can_fire or is_reloading or shots_fired >= max_projectiles:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = projectile_spawn.global_position
	projectile.rotation = cannon.global_rotation  # Ensure projectile follows cannon rotation
	projectile.tank_owner = self

	if projectile.has_signal("destroyed"):
		projectile.destroyed.connect(_on_projectile_destroyed)

	get_tree().root.add_child(projectile)

	# Play shoot sound
	if shoot_sound:
		shoot_sound.play()

	shots_fired += 1
	can_fire = false
	can_move = false  # Prevent movement when shooting

	cooldown_timer.start()
	await cooldown_timer.timeout  # Wait for cooldown
	can_move = true  # Re-enable movement after shooting

	if shots_fired >= max_projectiles:
		is_reloading = true
		reload_timer.start()

# Cooldown and reload handling
func _on_cooldown_timer_timeout():
	can_fire = true

func _on_reload_timer_timeout():
	shots_fired = 0
	is_reloading = false

func _on_projectile_destroyed():
	# Optional for future use
	pass

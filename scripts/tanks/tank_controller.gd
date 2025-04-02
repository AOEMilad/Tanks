# res://scripts/tanks/tank_controller.gd
extends CharacterBody2D

class_name TankController

# Tank properties
@export var max_speed: float = 150.0
@export var acceleration: float = 500.0
@export var friction: float = 700.0
@export var rotation_speed: float = 3.0

# Shooting properties
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.5
@export var max_projectiles: int = 5

# State tracking
var can_fire: bool = true
var active_projectiles: int = 0

# Components
@onready var cannon = $Cannon
@onready var projectile_spawn = $Cannon/ProjectileSpawn
@onready var cooldown_timer = $CooldownTimer

func _ready():
	cooldown_timer.wait_time = fire_cooldown
	cooldown_timer.one_shot = true

func _physics_process(delta):
	handle_movement(delta)
	handle_rotation(delta)
	move_and_slide()

# Handles tank movement based on input
func handle_movement(delta):
	var input_vector = Vector2.ZERO
	
	# This will be overridden in player and AI implementations
	input_vector = get_movement_input()
	
	# Apply acceleration or friction
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# Base method to be overridden
func get_movement_input() -> Vector2:
	return Vector2.ZERO

# Handles tank rotation based on input
func handle_rotation(delta):
	var target_direction = get_rotation_input()
	
	if target_direction != 0:
		rotation += target_direction * rotation_speed * delta

# Base method to be overridden
func get_rotation_input() -> float:
	return 0.0

# Shoots a projectile if conditions are met
func shoot():
	if can_fire and active_projectiles < max_projectiles:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = projectile_spawn.global_position
		projectile.rotation = cannon.global_rotation
		projectile.tank_owner = self
		
		# Connect to projectile destroyed signal to track active count
		projectile.destroyed.connect(_on_projectile_destroyed)
		
		# Add projectile to game world
		get_tree().get_root().add_child(projectile)
		
		# Start cooldown and increase active projectile count
		can_fire = false
		active_projectiles += 1
		cooldown_timer.start()

# Called when cooldown timer completes
func _on_cooldown_timer_timeout():
	can_fire = true

# Called when a projectile is destroyed
func _on_projectile_destroyed():
	active_projectiles -= 1

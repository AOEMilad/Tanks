# res://scripts/projectiles/projectile.gd
extends Area2D

class_name Projectile

# Projectile properties
@export var speed: float = 300.0
@export var lifetime: float = 3.0
@export var bounce_count: int = 1

# References
var tank_owner = null

# State tracking
var bounces_remaining: int = 0
var direction: Vector2 = Vector2.RIGHT

# Signal when projectile is destroyed
signal destroyed

func _ready():
	bounces_remaining = bounce_count
	direction = Vector2.RIGHT.rotated(rotation)
	
	# Set up lifetime timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	timer.start()

func _physics_process(delta):
	# Move projectile
	position += direction * speed * delta

func _on_body_entered(body):
	# Handle collision with obstacles
	if body is Obstacle:
		handle_obstacle_collision(body)
	# Handle collision with tanks
	elif body is TankController and body != tank_owner:
		handle_tank_collision(body)

func handle_obstacle_collision(obstacle):
	if bounces_remaining > 0:
		# Calculate bounce direction
		var collision_normal = (global_position - obstacle.global_position).normalized()
		direction = direction.bounce(collision_normal)
		rotation = direction.angle()
		bounces_remaining -= 1
	else:
		destroy()

func handle_tank_collision(tank):
	# Damage the tank
	if tank.has_method("take_damage"):
		tank.take_damage()
	
	# Destroy the projectile
	destroy()

func _on_lifetime_expired():
	destroy()

func destroy():
	# Emit signal before destroying
	emit_signal("destroyed")
	queue_free()

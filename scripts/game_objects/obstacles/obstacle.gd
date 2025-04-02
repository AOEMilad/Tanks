# res://scripts/game_objects/obstacles/obstacle.gd
extends StaticBody2D

class_name Obstacle

# Obstacle properties
@export var destructible: bool = false
@export var health: int = 1

func take_damage():
	if destructible:
		health -= 1
		if health <= 0:
			destroy()

func destroy():
	# Animation or particles could be added here
	queue_free()

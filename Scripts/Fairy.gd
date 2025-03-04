extends CharacterBody2D

var target:Node2D
var speed : float = 150.0

func _ready():
	target = %Player

func _process(delta):
	var direction = (target.global_position - global_position).normalized()
	var offset = Vector2.ZERO

	var movement = (direction + offset).normalized() * speed * delta
	velocity += movement
	move_and_slide()

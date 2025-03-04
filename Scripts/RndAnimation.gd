extends Node2D

func _ready():
	for animatedSprite in get_children():
		animatedSprite.play()

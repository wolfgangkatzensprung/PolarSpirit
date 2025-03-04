extends Node2D

const GAME = preload("res://Scenes/Game.tscn")

func _ready():
	var game = GAME
	print(str(game))
	call_deferred("LoadMainMenu")
	
func LoadMainMenu():
	get_tree().change_scene_to_packed(GAME)

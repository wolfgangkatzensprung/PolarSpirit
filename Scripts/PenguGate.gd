extends Node2D

@export var requiredPenguAmount:int = 12

func Open():
	# open gate by animation player
	pass

func _on_area_2d_body_entered(body):
	if get_parent().get_parent().penguAmountTotal >= requiredPenguAmount:
		Open()

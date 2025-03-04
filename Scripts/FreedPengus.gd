extends Node

func _ready():
	for child in get_children():
		child.visible = false
		
	SetPengusVisible()
	
func SetPengusVisible():
	var penguAmount = Game.penguAmountTotal
	print("SetPengus visible: ", penguAmount)
	
	var i:int = 0
	for child in get_children():
		if i < penguAmount:
			child.visible = true
			i += 1
		else:
			break


func _on_area_2d_body_entered(body):
	SetPengusVisible()

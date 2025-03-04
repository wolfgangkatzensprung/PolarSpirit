extends Node2D

var druckplatteAmount:int = 0
var activatedAmount:int = 0

func _ready():
	for child in get_children():
		druckplatteAmount += 1
	print("Raum hat ", druckplatteAmount, " Druckplatten")

func Success():
	$"../MovingPlatform".process_mode = Node.PROCESS_MODE_INHERIT
	
func _on_body_entered(body):
	print(str(body), " Activated")
	if body.has_method("SetActivated"):
		body.SetActivated()
	activatedAmount += 1
	if activatedAmount >= druckplatteAmount:
		Success()

func _on_body_exited(body):
	activatedAmount -= 1
	$"../MovingPlatform".process_mode = Node.PROCESS_MODE_DISABLED

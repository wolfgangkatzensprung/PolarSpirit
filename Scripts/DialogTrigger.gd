extends Area2D

@export var dialogResource = preload("res://Dialogues/test.dialogue")
@export var dialogTitle = "Guten Morgen"

func _on_body_entered(body):
	print("Show Dialog")
	$"..".EnterDialogue()
	%Player.canMove = false
	%Player.bubbleUnlocked = false
	%Player.TryResetBubble()	# if player is in bubble, force to release
	%Player.velocity = Vector2.ZERO
	var dialogBallon = DialogueManager.show_dialogue_balloon(dialogResource, dialogTitle)
	DialogueManager.dialogue_ended.connect(OnDialogFinished)

func OnDialogFinished(_resource):
	%Player.canMove = true
	%Player.bubbleUnlocked = true
	$"..".LeaveDialogue()
	queue_free()

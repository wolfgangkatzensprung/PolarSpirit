extends Area2D

signal reached

@export var playCompletionAnim:bool = true

func _on_body_entered(body):
	if(body.is_in_group("Player")):
		call_deferred("ReachEndPoint")
		
func ReachEndPoint():
	print("Level geschafft. Yay!")
	%Player.canMove = false
	%Player.bubbleUnlocked = false
	%Player.TryResetBubble()	# if player is in bubble, force to release
	%Player.velocity = Vector2.ZERO
	%Player.SetIdleState()
	if playCompletionAnim:
		%Player.PerformLevelCompletion()
		playCompletionAnim = false
	reached.emit()

extends CharacterBody2D
class_name Enemy

@onready var anim:AnimationPlayer =  $AnimationPlayer

@export var damage = 1

var canMove = true
var canFlip = true
var direction = -1

func Flip():
	canFlip = false
	direction = -direction
	$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x
	$FlipTimer.start()

func HitByBubble():
	if $AnimatedSprite2D.has_method("play"):
		$AnimatedSprite2D.play("Bubbled")
	print(name + " hit by Bubble")
	$Sprite2D_Bubble.visible = true
	$Sprite2D_Bubble.stop()	# stop burst anim in case its playing
	$Sprite2D_Bubble.frame = 0
	anim.stop()
	anim.play("BubbleBlink")
	canMove = false
	remove_from_group("Enemy")
	add_to_group("Bubbled")
	$DebubbleTimer.start()

func EscapeFromBubble():
	if $AnimatedSprite2D.has_method("play"):
		$AnimatedSprite2D.play("Walk")
	print (name + " escaped Bubble")
	$Sprite2D_Bubble.play("BubbleBurst")
	remove_from_group("Bubbled")
	call_deferred("add_to_group", "Enemy")
	canMove = true
	
func GetDamage():
	return damage

func OnDeathZoneEntered():
	queue_free()

func _on_debubble_timer_timeout():
	anim.stop()
	call_deferred("EscapeFromBubble")
	
func _on_flip_timer_timeout():
	canFlip = true

func _on_sprite_2d_bubble_animation_finished():	# on bubble burst animation finished
	$Sprite2D_Bubble.visible = false

func _on_bubble_jump_area_body_entered(body):
	print("Body entered BubbleJumpArea of ", name)
	if !body.has_method("BubbleJump"):
		return
	
	#if is_in_group("Enemy") and body.has_method("ApplyDamage"):
		#body.ApplyDamage(damage)
	
	if is_in_group("Bubbled"):
		body.BubbleJump()
		$DebubbleTimer.stop()
		$DebubbleTimer.emit_signal("timeout")

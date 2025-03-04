extends RigidBody2D
class_name Bubble

const RND_BUBBLE_POP_SOUND = preload("res://Audio/SFX/Rnd_BubblePopSound.tres")
const P_BUBBLE_EXPLOSION = preload("res://Assets/Particles/P_BubbleExplosion.tscn")

@export var minVelocity = 100.0
@export var maxVelocity = 1800.0
@export var orderIndex = 49	## ordering layer after leaving player parenthood

func _ready():
	SetScale(Vector2.ONE * 0.01)
	$Sprite2D.play()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($AudioStreamPlayer2D_BubbleFly, "volume_db", 0.0, 1.5)	# FadeIn
	
func SetScale(s):
	$Sprite2D.scale = s;
	$CollisionShape2D.scale = s;
	$bubbleglow.scale = s;
	$Light.scale = s;
	
func SetVelocity(v):
	if v.x < 0:
		linear_velocity.x = clamp(v.x, -maxVelocity, -minVelocity)
	else:
		linear_velocity.x = clamp(v.x, minVelocity, maxVelocity)
	print("Bubble Velocity: ", linear_velocity.x)

func StartBubbleShot():
	$PopTimer.start()
	freeze = false
	visibility_layer = orderIndex
	$AudioStreamPlayer2D_BubbleFly.bus = "BubbleShot"

func PopBubble():
	AudioManager.PlaySound(RND_BUBBLE_POP_SOUND)
	var particles = P_BUBBLE_EXPLOSION.instantiate()
	get_parent().add_child(particles, 1)
	particles.set_emitting(true)
	particles.position = position
	queue_free()

func _on_body_entered(body):
	if body.has_method("HitByBubble"):
		body.HitByBubble()
		PopBubble()
	else:
		PopBubble()

func _on_pop_timer_timeout():
	PopBubble()

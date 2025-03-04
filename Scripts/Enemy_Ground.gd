extends Enemy

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const ENEMY_HUH = preload("res://Audio/SFX/EnemyHuh.wav")

@export var speed = 130.0
var startSpeed:float

var raycastLength = 20
var raycastDirection = Vector2(1, 0)

@onready var raycastHorizontal = $RayCast2D_Horizontal
@onready var raycastVertical = $RayCast2D_Vertical

func _ready():
	$AnimatedSprite2D.play("Walk")
	startSpeed = speed
	call_deferred("SetBubbleColliderDisabled", true)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if canMove:
		MovePatrol(delta)
	
	move_and_slide()

func MovePatrol(_delta):
	velocity.x = direction * speed
	
	if (canFlip && (raycastHorizontal.is_colliding() || !raycastVertical.is_colliding())):
		Flip()

func HitByBubble():
	super.HitByBubble()
	speed = 0.0
	$AudioStreamPlayer2D.stream_paused = true
	AudioManager.PlaySound(ENEMY_HUH)
	call_deferred("ResetVelocity", position)
	call_deferred("SetBubbleColliderDisabled", false)
	
func EscapeFromBubble():
	super.EscapeFromBubble()
	$AudioStreamPlayer2D.stream_paused = false
	speed = startSpeed
	call_deferred("SetBubbleColliderDisabled", true)

func Flip():
	super.Flip()
	raycastHorizontal.target_position.x *= -1.0
	raycastVertical.position.x *= -1.0
	$CollisionPolygon2D_EnemyShape.scale.x *= -1.0
	
func ResetVelocity(pos):
	position = pos
	speed = 0.0
	velocity = Vector2.ZERO

func SetBubbleColliderDisabled(b):
	$CollisionShape2D_BubbleShape.disabled = b

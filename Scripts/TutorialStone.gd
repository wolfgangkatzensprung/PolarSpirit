extends Sprite2D

@export var controllerSprite:Texture2D
@export var startSprite:Texture2D ## keys+mouse sprite

func _ready():
	SetSprite(UserInterface.controllerMode)

func SetSprite(cMode):
	if not cMode:
		set_texture(startSprite)
		print("Keys Mode: ", startSprite)
	else:
		set_texture(controllerSprite)
		print("Controller Mode: ", controllerSprite)

extends TextureRect

@export var controllerSprite:Texture2D
@export var startSprite:Texture2D ## keys+mouse sprite

@export var keysSize:Vector2 = Vector2(399, 187)
@export var controllerSize:Vector2 = Vector2(256, 256)

func _ready():
	size = keysSize
	SetSprite(UserInterface.controllerMode)

func SetSprite(cMode):
	if not cMode:
		set_texture(startSprite)
		size = keysSize
		print("Keys Mode: ", startSprite)
	else:
		set_texture(controllerSprite)
		size = controllerSize
		print("Controller Mode: ", controllerSprite)

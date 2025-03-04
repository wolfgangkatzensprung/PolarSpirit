extends Control

@onready var optionButton = $HBoxContainer/OptionButton

const WINDOW_MODES:Array[String] = [
	"Full-Screen",
	"Window Mode"
]

func _ready():
	SetSelectionOptions()

func SetSelectionOptions():
	for windowMode in WINDOW_MODES:
		optionButton.add_item(windowMode)

func _on_option_button_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

extends Control
class_name UserInterface

@onready var menus = [$Menus/PauseMenu, $Menus/MainMenu, $Menus/SettingsMenu, $Menus/ControlsMenu, $Menus/SoundMenu, $Menus/ControlsPauseMenu, $Menus/SoundPauseMenu]
@onready var menusByName = {"PauseMenu":$Menus/PauseMenu, "MainMenu":$Menus/MainMenu, "SettingsMenu":$Menus/SettingsMenu, "ControlsMenu":$Menus/ControlsMenu, "SoundMenu":$Menus/SoundMenu, "ControlsPauseMenu": $Menus/ControlsPauseMenu, "SoundPauseMenu": $Menus/SoundPauseMenu}

@onready var penguDisplay = $HBox_Pengus

static var controllerMode = false
signal controllerModeChanged

func _ready():
	SetKeysMode()

func _input(event):
	if !controllerMode and ( event is InputEventJoypadButton or event is InputEventJoypadMotion ):
		SetControllerMode()

	elif controllerMode and ( event is InputEventMouse or event is InputEventKey ):
		SetKeysMode()

func SetControllerMode():
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	controllerMode = true
	controllerModeChanged.emit(controllerMode)
	print("Controller Mode enabled")
	$"Label_UI Debug".text = "Controller Mode"
func SetKeysMode():
	#if $"../..".currentLevel == null:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	controllerMode = false
	controllerModeChanged.emit(controllerMode)
	print("Controller Mode disabled")
	$"Label_UI Debug".text = "Keys Mode"

func Reset():
	for menu in menusByName.values():
		menu.visible = false

func ShowMenu(menuName):
	for menu in menus:
		menu.visible = menu.name == menuName

func HideMenu(menuName):
	for menu in menus:
		menu.visible = menu.name != menuName

func HideAllMenus():
	for menu in menusByName.values():
		menu.visible = false

func Toggle(name):
	if (menusByName[name].visible):
		HideAllMenus()
	else:
		ShowMenu(name)

func SetPenguAmount(penguAmount):
	var penguText = str(penguAmount) + "x"
	UpdatePenguTexts(penguText)
	
func SetPenguAmount_LastTransition(penguAmount):
	var penguText = "You freed " + str(penguAmount) + " of 11\npenguins!"
	UpdatePenguTexts(penguText)	
	
func UpdatePenguTexts(pengusFreedText):
	$HBox_Pengus/Label_CollectedPengus.text = pengusFreedText
	$"../TransitionOverlay/TextureRect_TransitionScreen/HBox_Pengus_TransitionScreen/Label_CollectedPengus".text = pengusFreedText

func DisplayPengus():
	$HBox_Pengus/AnimationPlayer_Pengus.play("PenguCollected")

extends Control

@export var focusElement:Control	## button that grabs focus when menu is loaded
var focusOwner ## element that currently has focus

func _ready():
	get_viewport().gui_focus_changed.connect(OnFocusChanged)
	visibility_changed.connect(UpdateFocus)

func UpdateFocus():
	if is_visible_in_tree():
		if UserInterface.controllerMode:
			GrabFocus()
		else:
			LoseFocus()

func GrabFocus():
	print(focusElement.name + " grab Focus")
	focusElement.grab_focus()

func LoseFocus():
	if focusOwner != null:
		print(focusOwner.name + " lose Focus")
		focusOwner.release_focus()

func OnFocusChanged(focOwner):
	if focOwner != null:
		focusOwner = focOwner
		print(focusOwner.name, " has Focus")

func _on_user_interface_controller_mode_changed(_cMode):
	UpdateFocus()

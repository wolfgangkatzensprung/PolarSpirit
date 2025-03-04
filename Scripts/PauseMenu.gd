extends "MenuBase.gd"

func _on_sound_button_pressed():
	AudioManager.PlayUISound()
	%UserInterface.HideAllMenus()
	%UserInterface.ShowMenu("SoundPauseMenu")

func _on_controls_button_pressed():
	AudioManager.PlayUISound()
	%UserInterface.HideAllMenus()
	%UserInterface.ShowMenu("ControlsPauseMenu")

extends TextureRect

func ShowPengus():
	if $"../../..".levelIndex > 1:
		$HBox_Pengus_TransitionScreen/AnimationPlayer_Pengus_TransitionScreen.play("PenguCollected")

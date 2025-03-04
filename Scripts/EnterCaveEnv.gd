extends WorldEnvironment

func EnterCaveAudio():
	AudioManager.SetCaveSpace()

func LeaveCaveAudio():
	AudioManager.SetDefaultSpace()

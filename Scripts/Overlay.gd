extends Control

@onready var animFade = $AnimationPlayer_Fade
@onready var animLoad = $AnimationPlayer_LoadingScreen

func _ready():
	set_visible(true)
	$TextureRect_LoadingScreen.modulate.a = 0
	FadeIn()

func FadeIn():
	animFade.play("Overlay_FadeIn")
func FadeOut():
	animFade.play("Overlay_FadeOut")

func ToLoadingScreen():
	print("To Loading Screen")
	animLoad.play("ToLoadingScreen")
func LoadingDone():
	animLoad.play("LoadingDone")

func ShowCutsceneBars():
	if not $AnimationPlayer_Cutscene.assigned_animation == "StartCutscene":
		$AnimationPlayer_Cutscene.play("StartCutscene")
func ResetCutsceneBars():
	$AnimationPlayer_Cutscene.play("EndCutscene")
	
func ShowLevelTransitionScreen():
	$AnimationPlayer_TransitionScreen.play("LevelTransition")

func SetLevelProgress(i):
	$TextureRect_TransitionScreen/LevelProgress.text = str(i) + " / 8"

func GetIsFading():
	return $AnimationPlayer_Cutscene.current_animation != "" || $AnimationPlayer_Fade.current_animation != "" || $AnimationPlayer_LoadingScreen.current_animation != "" || $AnimationPlayer_TransitionScreen.current_animation != ""

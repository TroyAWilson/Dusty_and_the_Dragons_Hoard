extends Node2D

var bkg: AudioStreamPlayer

func _ready() -> void:
	bkg = AudioController.playIntro()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		bkg.stop()
		SceneTransition.change_scene(SceneTransition.instructions)

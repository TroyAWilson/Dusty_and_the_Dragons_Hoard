extends Node2D

var bkg: AudioStreamPlayer

func _ready() -> void:
	bkg = AudioController.playIntro()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_a"):
		SceneTransition.change_scene(SceneTransition.mainGame)

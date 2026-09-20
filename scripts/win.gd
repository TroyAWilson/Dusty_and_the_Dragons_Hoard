extends Node2D

func _ready() -> void:
	AudioController.playWin()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_start"):
		GameController.reset()
		SceneTransition.change_scene(SceneTransition.mainGame)

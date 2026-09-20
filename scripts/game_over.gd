extends Node2D

func _ready() -> void:
	print("game over scene entered and ready")
	AudioController.playGameOver()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"): #I think this works cause we're loading the scene again?
		GameController.reset()
		SceneTransition.change_scene(SceneTransition.mainGame)

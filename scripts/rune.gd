extends Node2D

signal roomFinished

@onready var runeSprite := $runeSprite

var rune : String

func setup(room: Dictionary):
	rune = room["newRune"]

func _ready() -> void:
	runeSprite.texture = GameController.runes[rune].sprite
	
	var start_y = runeSprite.position.y
	
	var tween := create_tween()
	tween.set_loops()
	tween.parallel().tween_property(
		runeSprite,
		"rotation",
		deg_to_rad(3),
		0.8
	)
	tween.tween_property(
		runeSprite,
		"position:y",
		start_y - 2,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		runeSprite,
		"position:y",
		start_y + 2,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_a"):
		GameController.addRuneToDeck(rune)
		AudioController.playPickupRune()
		roomFinished.emit()

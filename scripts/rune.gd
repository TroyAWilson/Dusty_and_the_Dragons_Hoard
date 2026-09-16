extends Node2D

signal roomFinished



@onready var runeSprite := $runeSprite

var rune : String

func setup(room:Dictionary):
	print(room)
	print("setting up for new rune: " + room["newRune"])
	rune = room["newRune"]

func _ready() -> void:
	runeSprite.texture = GameController.runes[rune].sprite
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_a"):
		GameController.addRuneToDeck(rune)
		
		roomFinished.emit()

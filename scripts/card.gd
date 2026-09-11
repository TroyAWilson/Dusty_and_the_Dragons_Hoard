extends Button

signal runeSelected(rune)

var runeName: String = ""
var runeTexture: Texture2D

var isSelected := false
var startingPosition: Vector2

@onready var runeSprite: Sprite2D = $Sprite2D
@onready var outline := $Outline

func setup(rune: String, texture: Texture2D) -> void:
	runeName = rune
	runeTexture = texture

func _ready() -> void:
	runeSprite.texture = runeTexture
	outline.visible = false
	
func setSelected(selected:bool) -> void:
	print(selected)
	
	isSelected = selected
	outline.visible = selected
	startingPosition = position

	var tween = create_tween()
	
	if selected:
		tween.tween_property(self, "position", startingPosition + Vector2(0,-5), 0.1)
	else:
		tween.tween_property(self, "position", startingPosition + Vector2(0,5), 0.1)


	
func _on_pressed() -> void:
	runeSelected.emit(self)
	
	#startingPosition = position
	#var tween = create_tween()
	#
	#if isSelected: #deselect if pressed again
		#isSelected = false
		#outline.visible = false
		#tween.tween_property(self, "position", startingPosition + Vector2(0,5), 0.1)
	#else:
		#isSelected = true
		#outline.visible = true
		#tween.tween_property(self, "position", startingPosition + Vector2(0,-5), 0.1)
		#
	#runeSelected.emit(runeName, isSelected)

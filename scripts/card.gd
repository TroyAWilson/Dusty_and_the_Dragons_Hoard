extends Button

signal runeSelected(rune)

var runeName: String = ""
var runeTexture: Texture2D

var isSelected := false
var startingPosition: Vector2

@onready var runeSprite: Sprite2D = $Visuals/Sprite2D
@onready var outline := $Visuals/Outline 
@onready var visuals := $Visuals

func setup(rune: String, texture: Texture2D) -> void:
	runeName = rune
	runeTexture = texture

func _ready() -> void:
	runeSprite.texture = runeTexture
	outline.visible = false
	
func setSelected(selected:bool) -> void:
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

func animateIn() -> void:
	visuals.position.y = 16
	
	var tween = create_tween()
	tween.tween_property(visuals, "position:y", 0.0, 0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

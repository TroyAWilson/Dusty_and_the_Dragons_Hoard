extends Node2D

var currentHand: Array[String] = []
var currentEnemy: Dictionary = {}

var selectedRunes: Array[Button] = []

@onready var enemySprite: AnimatedSprite2D = $EnemyArea/enemySprite
@onready var cardContainer := $cardContainer

var cardScene := preload("res://scenes/card.tscn")

func _ready() -> void:
	loadEnemy()
	loadHand()

	await get_tree().process_frame

	for card in cardContainer.get_children():
		print(
			"pos=", card.position,
			" size=", card.size,
			" min=", card.custom_minimum_size
		)

func setup(hand: Array[String]) -> void:
	currentHand = hand.duplicate()

	var enemyKey: String = GameController.rooms[GameController.roomIndex]["enemy"]
	currentEnemy = GameController.enemies[enemyKey].duplicate(true)

func loadHand() -> void:
	for runeName in currentHand:
		var card = cardScene.instantiate()
		var runeData = GameController.runes[runeName]
		
		card.setup(runeName, runeData['sprite'])
		
		card.runeSelected.connect(_on_rune_selected)
		
		cardContainer.add_child(card)
		
	await get_tree().process_frame
	if cardContainer.get_child_count() > 0:
		cardContainer.get_child(0).grab_focus()

func loadEnemy() -> void:
	var texture: Texture2D = currentEnemy["sprite"]

	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 3.0)

	# Frame 1
	var frame1 := AtlasTexture.new()
	frame1.atlas = texture
	frame1.region = Rect2(
		0,
		0,
		texture.get_width() / 2,
		texture.get_height()
	)

	# Frame 2
	var frame2 := AtlasTexture.new()
	frame2.atlas = texture
	frame2.region = Rect2(
		texture.get_width() / 2,
		0,
		texture.get_width() / 2,
		texture.get_height()
	)

	frames.add_frame("idle", frame1)
	frames.add_frame("idle", frame2)

	enemySprite.sprite_frames = frames
	enemySprite.play("idle")


func _on_rune_selected(card) -> void:
	if card in selectedRunes:
		selectedRunes.erase(card)
		card.setSelected(false)
		return
	
	if selectedRunes.size() >= 2:
		return
		
	selectedRunes.append(card)
	card.setSelected(true)
	print(selectedRunes.map(func(c):return c.runeName))

extends Node2D

@onready var roomContainer = $RoomContainer
@onready var fadeRect = $TransitionLayer/FadeRect
@onready var goldLabel := $CanvasLayer/gold
@onready var healthLabel := $CanvasLayer/health

var combatScene = preload("res://scenes/combat.tscn")
var goldScene = preload("res://scenes/gold.tscn")
var runeScene = preload("res://scenes/rune.tscn")

func _ready() -> void:
	fadeRect.color.a = 0.0
	loadCurrentRoom()
	updateGoldLabel()

func _process(_delta: float) -> void:
	# testing only
	if Input.is_action_just_pressed("start"):
		handleRoomChange()


func loadCurrentRoom() -> void:
	var room = GameController.rooms[GameController.roomIndex]

	match room["type"]:
		"combat":
			startCombat(room)
		"gold":
			startGoldRoom(room)
		"rune":
			startRuneRoom(room)

func startCombat(room: Dictionary) -> void:
	GameController.playerDeck.shuffle()
	GameController.drawStartingHand()

	var combat = combatScene.instantiate()
	combat.roomFinished.connect(handleRoomChange)
	combat.takeDamage.connect(handleTakeDamage)

	combat.setup(GameController.hand)

	roomContainer.add_child(combat)

func startGoldRoom(room: Dictionary) -> void:
	var goldRoom = goldScene.instantiate()
	goldRoom.roomFinished.connect(handleRoomChange)
	goldRoom.setup(room["amount"])

	goldRoom.addGold.connect(updateGoldLabel)

	roomContainer.add_child(goldRoom)

func startRuneRoom(room:Dictionary) -> void:
	var runeRoom = runeScene.instantiate()
	runeRoom.roomFinished.connect(handleRoomChange)
	runeRoom.setup(room)
	roomContainer.add_child(runeRoom)


func handleRoomChange() -> void:
	await fade_out()

	clearCurrentRoom()

	GameController.roomIndex += 1

	if GameController.roomIndex >= GameController.rooms.size():
		print("No more rooms!")
		return

	loadCurrentRoom()
	
	await get_tree().process_frame
	await fade_in()

func handleTakeDamage() -> void:
	print(GameController.playerHealth)
	var healthString = str(GameController.playerHealth) + "/" + str(GameController.maxHealth)
	healthLabel.text = "[font_size=10][color=2c2137]" + healthString

func clearCurrentRoom() -> void:
	for child in roomContainer.get_children():
		child.queue_free()

func updateGoldLabel() -> void:
	goldLabel.text = "[font_size=10][color=2c2137]" + str(GameController.playerGold)

#Fade transition

func fade_out() -> void:
	var tween = create_tween()

	tween.tween_property(
		fadeRect,
		"color:a",
		1.0,
		0.5
	)

	await tween.finished


func fade_in() -> void:
	var tween = create_tween()

	tween.tween_property(
		fadeRect,
		"color:a",
		0.0,
		0.5
	)

	await tween.finished

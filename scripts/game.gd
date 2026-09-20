extends Node2D

@onready var roomContainer = $RoomContainer
@onready var fadeRect = $TransitionLayer/FadeRect
@onready var goldLabel := $CanvasLayer/gold
@onready var healthLabel := $CanvasLayer/health
@onready var blockLabel := $CanvasLayer/block
@onready var textBox := $textBox
@onready var textBoxText := $textBox/textBoxText

var combatScene = preload("res://scenes/combat.tscn")
var goldScene = preload("res://scenes/gold.tscn")
var runeScene = preload("res://scenes/rune.tscn")
var shopScene = preload("res://scenes/shop.tscn")

var currentQuip := 0
const textBoxQuips := [
	"A Canary? In this coal mine?", #canary
	"Nice ride", #frog
	"Gross...", #ooze
	"Aw hell. He’s got paperwork.", #mole
	"I should have guessed" #dragon
]

var bkg : AudioStreamPlayer

func _ready() -> void:
	bkg = AudioController.playBkg()
	fadeRect.color.a = 0.0
	loadCurrentRoom()
	updateGoldLabel()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_select"):
		bkg.stream_paused = !bkg.stream_paused

func loadCurrentRoom() -> void:
	var room = GameController.rooms[GameController.roomIndex]

	match room["type"]:
		"combat":
			startCombat(room)
		"gold":
			startGoldRoom(room)
		"rune":
			startRuneRoom(room)
		"shop":
			startShop(room)

func startCombat(room: Dictionary) -> void:
	GameController.playerDeck.shuffle()
	GameController.drawStartingHand()

	var combat = combatScene.instantiate()
	
	#signals
	combat.roomFinished.connect(handleRoomChange)
	combat.takeDamage.connect(handleTakeDamage)
	combat.textBoxTime.connect(showTextBox)
	combat.updateBlock.connect(handleBlock)
	combat.gameOver.connect(handleGameOver)
	combat.gainGold.connect(updateGoldLabel)
	
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

func startShop(room:Dictionary) -> void:
	var shopRoom = shopScene.instantiate()
	shopRoom.setup(room)
	shopRoom.roomFinished.connect(handleRoomChange)
	shopRoom.updateHealth.connect(handleTakeDamage)
	shopRoom.updateMoney.connect(updateGoldLabel)
	
	roomContainer.add_child(shopRoom)

func handleRoomChange() -> void:
	await fade_out()

	clearCurrentRoom()

	GameController.roomIndex += 1
	
	print("entering room " + str(GameController.roomIndex) + "/" + str(GameController.rooms.size()))
	if GameController.roomIndex >= GameController.rooms.size():
		bkg.stop()
		SceneTransition.change_scene(SceneTransition.gameWin)
	else:
		loadCurrentRoom()
		
		await get_tree().process_frame
		await fade_in()

func handleTakeDamage() -> void:
	#var healthString = str(GameController.playerHealth) + "/" + str(GameController.maxHealth)
	var healthString = str(GameController.playerHealth)
	healthLabel.text = "[font_size=8][color=2c2137]" + healthString

func handleBlock() -> void:
	var currentBlock := GameController.playerBlock
	blockLabel.text = "[font_size=10][color=2c2137]" + str(currentBlock)

func clearCurrentRoom() -> void:
	for child in roomContainer.get_children():
		child.queue_free()

func updateGoldLabel() -> void:
	goldLabel.text = "[font_size=8][color=2c2137]" + str(GameController.playerGold)

func showTextBox() -> void:
	const textStyles = "[font_size=8][wave][color=2c2137][center]"
	textBoxText.text = textStyles + textBoxQuips[currentQuip]
	textBox.visible = true
	
	await get_tree().create_timer(3).timeout
	
	textBox.visible = false
	currentQuip += 1

func handleGameOver() -> void:
	print("you lose")
	bkg.stop()
	SceneTransition.change_scene(SceneTransition.gameOver)

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

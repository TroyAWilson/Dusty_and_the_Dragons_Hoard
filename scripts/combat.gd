extends Node2D

signal roomFinished

#the other junk
var currentHand: Array[String] = []
var currentEnemy: Dictionary = {}
var currentEnemyIntentionIndex := 0
var currentEnemyIntention: Dictionary
var selectedRunes: Array[Button] = []
var casting := false

#onreadys
@onready var enemySprite: AnimatedSprite2D = $EnemyArea/enemySprite
@onready var enemyHealthBar := $EnemyArea/enemyHealthBar
@onready var enemyIntentionSprite := $EnemyArea/intention
@onready var cardContainer := $cardContainer

#preloads
var cardScene := preload("res://scenes/card.tscn")
var enemyAtkPreload := preload("res://media/atkV1.png")
var enemyBlockPreload := preload("res://media/blockV1.png")

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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_b") and selectedRunes.size() == 2:
		handleSpellCast()

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
	
		card.animateIn()

		
	await get_tree().process_frame
	
	if cardContainer.get_child_count() > 0:
		cardContainer.get_child(0).grab_focus()

func newHand() -> void:
	for child in cardContainer.get_children():
		child.queue_free()
		
	selectedRunes.clear()
		
	GameController.drawNewHand()
	loadHand()

func loadEnemy() -> void:
	#load sprite
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
	
	#load health
	print(currentEnemy)
	enemyHealthBar.max_value = currentEnemy.health
	enemyHealthBar.value = enemyHealthBar.max_value
	
	#load attack
	currentEnemyIntention = currentEnemy.attacks[currentEnemyIntentionIndex]
	loadEnemyIntention()

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

func handleSpellCast() -> void:
	casting = true
	var spellName = normalizeSpell(selectedRunes[0].runeName, selectedRunes[1].runeName)
	print('casting ' + spellName)
	
	var spellInfo = GameController.spells[spellName]
	if "damage" in spellInfo["types"]:
		print('damaging spell boom!')
		if "hits" in spellInfo:
			dealDamage(spellInfo["damage"], spellInfo["hits"])
		else:
			dealDamage(spellInfo["damage"])
	
	if "block" in spellInfo["types"]:
		print("blocked it!")
	
	if "effect" in spellInfo["types"]:
		print("do an effect?") #i dont really know what this means yet
	
	casting = false
	
func normalizeSpell(rune1:String, rune2:String) -> String:
	var temp = [rune1, rune2]
	temp.sort()
	return temp[0] + "_" + temp[1]

func dealDamage(damage:int, hits:int=1) -> void:
	print("dealing " + str(damage) + " points of damage " + str(hits) + " times")

	if hits == -1:
		var hitCount = 1
		var threshold = 101
		print('calculate number of hits')
		while randi_range(1,100) < threshold:
			hitCount += 1
			threshold -= 10
			
		print("hitcount: " + str(hitCount))
		
		hits = hitCount
	
	for i in range(hits):
		#add sound here
		currentEnemy.health -= damage
		enemyHealthBar.value = currentEnemy.health
		await get_tree().create_timer(0.2).timeout

	if currentEnemy.health <= 0:
		print('you have defeated the enemy')
		roomFinished.emit()
		
	else:
		handleEnemyTurn()
		newHand()
	
func loadEnemyIntention() -> void:
	if currentEnemyIntention.type == "attack":
		enemyIntentionSprite.texture = enemyAtkPreload
	elif currentEnemyIntention.type == "block":
		enemyIntentionSprite.texture = enemyBlockPreload
	
func handleEnemyTurn() -> void:
	currentEnemyIntentionIndex += 1
	currentEnemyIntention = currentEnemy.attacks[currentEnemyIntentionIndex]
	loadEnemyIntention()

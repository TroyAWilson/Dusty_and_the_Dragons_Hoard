extends Node2D

signal roomFinished
signal takeDamage
signal textBoxTime
signal updateBlock
signal gameOver
signal gainGold

#the other junk
var currentHand: Array[String] = []
var currentEnemy: Dictionary = {}
var currentEnemyIntentionIndex := 0
var currentEnemyIntention: Dictionary
var selectedRunes: Array[Button] = []
var casting := false
var playerBlock := 0
var currentEnemyBlock := 0
var delayedDamage := 0

#onreadys
@onready var enemySprite: AnimatedSprite2D = $EnemyArea/enemySprite
@onready var enemyHealthBar := $EnemyArea/enemyHealthBar
@onready var enemyIntentionSprite := $EnemyArea/intention
@onready var enemyDamageNumber := $EnemyArea/dmgNum
@onready var enemyBlockContainer := $EnemyArea/BlockContainer
@onready var enemyBlockValue := $EnemyArea/BlockContainer/blockValue
@onready var hitSprite := $hit
@onready var cardContainer := $cardContainer

#preloads
var cardScene := preload("res://scenes/card.tscn")
var enemyAtkPreload := preload("res://media/atkV2.png")
var enemyBlockPreload := preload("res://media/blockV1.png")

func _ready() -> void:
	loadEnemy()
	loadHand()

	await get_tree().process_frame

	textBoxTime.emit()

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
	currentHand = GameController.hand.duplicate()

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
		
	AudioController.playBoop()
	selectedRunes.append(card)
	card.setSelected(true)
	print(selectedRunes.map(func(c):return c.runeName))

func handleSpellCast() -> void:
	casting = true
	
	var instantDeath := false
	
	if delayedDamage != 0:
		handleDelayedDamage()
		if GameController.playerHealth <= 0:
			gameOver.emit()
			casting = false
			return
	
	var spellName = normalizeSpell(selectedRunes[0].runeName, selectedRunes[1].runeName)
	print('casting ' + spellName)
	
	var spellInfo = GameController.spells[spellName]
	if "damage" in spellInfo["types"]:
		if "hits" in spellInfo:
			await dealDamage(spellInfo["damage"], spellInfo["hits"])
		else:
			await dealDamage(spellInfo["damage"])
	if "block" in spellInfo["types"]:
		handleBlock(spellInfo["block"])
	if "effect" in spellInfo["types"]:
		match spellInfo["effect"]:
			"stun":
				AudioController.playStun()
				currentEnemyIntention = {"type":"stunned"}
			"gainGold":
				AudioController.playCoin()
				GameController.playerGold += spellInfo["amount"]
				gainGold.emit()
			"selfDamage":
				GameController.playerHealth -= spellInfo['selfDamage']
				takeDamage.emit()
			"bloodMoney":
				GameController.playerHealth -= 2
				takeDamage.emit()
				
				GameController.playerGold += 20
				gainGold.emit()
			"delayedDamage":
				delayedDamage = spellInfo['delayedDamage']
			"gamble": #30/70 chance you instantly die or kill the enemy
				var threshold = 15 if "Dice in a Jar" in GameController.playerItems else 30
				if randi_range(1,100) <= threshold:
					print('You LOST the death death roll')
					instantDeath = true
				else:
					print('You WON the death death roll')
					await dealDamage(10000000)
			"_":
				print("uh oh: " + spellInfo["effect"])
	
	if currentEnemy.health <= 0:
		roomFinished.emit()
	else:
		handleEnemyTurn(instantDeath)
		newHand()
	
	casting = false
	
	
func normalizeSpell(rune1:String, rune2:String) -> String:
	var temp = [rune1, rune2]
	temp.sort()
	return temp[0] + "_" + temp[1]

func handleBlock(block:int) -> void:
	AudioController.playBlock2()
	if block == -2:
		block = GameController.playerGold
	playerBlock += block
	GameController.playerBlock = playerBlock

func dealDamage(damage:int, hits:int=1) -> void:
	if damage == -2:
		damage = GameController.playerGold
		
		if "Spicy Juice" in GameController.playerItems:
			print("spicy juice is in inventory")
			var spiceCount = GameController.playerItems.count("Spicy Juice")
			damage += (10 * spiceCount)

		
		#gold is proving to be very strong,
		#so lets reduce the gold per use of it
		GameController.playerGold -= 5
		if GameController.playerGold < 0:
			GameController.playerGold = 0
		gainGold.emit()
	
	if hits == -1:
		var hitCount = 1
		var threshold = 101
		while randi_range(1,100) < threshold:
			hitCount += 1
			threshold -= 10
		hits = hitCount
	elif hits == -2:
		hits = GameController.playerGold
	
	if "Red Tear Bottle" in GameController.playerItems and GameController.playerHealth <= GameController.maxHealth * 0.5:
			damage *= 2
			print('red tear bottle online: ' + str(damage))
			
	var baseDmg = damage
	for i in range(hits):
		if currentEnemy.health <= 0:
			break
		
		AudioController.playHit()
		displayHit()
		
		var hitDamage = baseDmg
		if currentEnemyBlock > 0:
			var blocked = min(currentEnemyBlock, hitDamage)
			currentEnemyBlock -= blocked
			hitDamage -= blocked
		
		currentEnemy.health -= hitDamage
		enemyHealthBar.value = currentEnemy.health
		await get_tree().create_timer(0.2).timeout

	
func loadEnemyIntention() -> void:
	if currentEnemyIntention.type == "attack":
		enemyIntentionSprite.texture = enemyAtkPreload
		enemyDamageNumber.text = "[font_size=8][color=edb4a1]" + str(currentEnemyIntention.damage)
	elif currentEnemyIntention.type == "block":
		enemyIntentionSprite.texture = enemyBlockPreload
		enemyDamageNumber.text = ""
	
func handleEnemyTurn(death:bool = false) -> void:
	currentEnemyBlock = 0 
	
	if death:
		print("You lost the gamble")
		GameController.playerHealth = 0
		takeDamage.emit()
		
		if "Faerie in a Can" in GameController.playerItems:
			GameController.playerHealth = round(GameController.maxHealth / 2)
			GameController.playerItems.erase("Faerie in a Can")
			takeDamage.emit()
		else:
			gameOver.emit()
			
		return
	
	if currentEnemyIntention.type == "attack":
		var remainingBlock = playerBlock - currentEnemyIntention.damage
		var dmg = 0
		playerBlock = 0	
		if remainingBlock < 0:
			dmg = abs(remainingBlock)
			
		AudioController.playPlayerHit()
		GameController.playerTakeDamage(dmg)
		takeDamage.emit()
		handleBlock(0) #set player block back to 0 after each round
		
		if GameController.playerHealth <= 0 and "Faerie in a Can" in GameController.playerItems:
			GameController.playerHealth = round(GameController.maxHealth / 2)
			GameController.playerItems.erase("Faerie in a Can")
			takeDamage.emit() #this reads weird but takeDamage just updates the health label
		
		if GameController.playerHealth <= 0:
			gameOver.emit()
	elif currentEnemyIntention.type == "block":
		currentEnemyBlock = currentEnemyIntention.block
		enemyBlockValue.text = "[font_size=8]" + str(currentEnemyBlock)
	elif currentEnemyIntention.type == "stunned":
		print('stunned do, nothing')
		
	if currentEnemyBlock != 0:
		enemyBlockContainer.visible = true
	else:
		enemyBlockContainer.visible = false
		
	currentEnemyIntentionIndex += 1
	if currentEnemyIntentionIndex >= currentEnemy.attacks.size():
		currentEnemyIntentionIndex = 0
	currentEnemyIntention = currentEnemy.attacks[currentEnemyIntentionIndex]
	loadEnemyIntention()

func displayHit() -> void:
	hitSprite.visible = true
	await get_tree().create_timer(0.1).timeout
	hitSprite.visible = false

func handleDelayedDamage() -> void:
	print("taking delayed damage: " + str(delayedDamage))
	AudioController.playPlayerHit()
	GameController.playerTakeDamage(delayedDamage)
	takeDamage.emit()
	delayedDamage = 0

extends Node2D

signal roomFinished
signal updateHealth
signal updateMoney

@onready var shopKeeperText := $shopKeeperText
var text: String
var purchased := false
var items = [
	{
		"label":"Heart Shaped Soda",
		"price":10,
		"effect": lifeUp as Callable
	},
	{
		"label":"Spicy Juice Pouch",
		"price":15,
		"effect": fireRunesUp as Callable
	},
	{
		"label":"Red Tear Bottle",
		"price":20,
		"effect": redTearStone as Callable
	},
	{
		"label":"Faerie in a Can",
		"price":35,
		"effect": redTearStone as Callable
	},
	{
		"label":"Dice in a Jar",
		"price":20,
		"effect": redTearStone as Callable
	},
	#--SOME IDEAS FOR ITEMS--
	#double damage at low health
	#if you would die, drop to 1 instead
	#death_death is less likely to kill you
	#storm damage up
	#storm spells have small chance to stun on hit
	#double gold has a 25% chance to result in +100 gold
]

var rand:int

func setup(room:Dictionary) -> void:
	rand = randi_range(0, items.size()-1) 
	text = "[wave][font_size=8]" + items[rand].label + ", only " + str(items[rand].price) + " gold"
	
func _ready() -> void:
	shopKeeperText.text = text
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_a") and not purchased:
		purchased = true
		if GameController.playerGold >= items[rand].price:
			items[rand].effect.call()
			AudioController.playPurchase()
			GameController.playerGold -= items[rand].price
			GameController.playerItems.append(items[rand].label)
			updateMoney.emit()
			shopKeeperText.text = "[wave][font_size=8]Thanks gamer!"
			await get_tree().create_timer(1).timeout
			roomFinished.emit()
		else:
			AudioController.playWompSynth()
			shopKeeperText.text = "[wave][font_size=8]Brokie..."
			await get_tree().create_timer(1).timeout
			roomFinished.emit()	
			
	if Input.is_action_just_pressed("gb_b"):
		roomFinished.emit()	

#shop functions
func lifeUp() -> void:
	GameController.maxHealth += 10
	GameController.playerHealth += 10
	updateHealth.emit()
	
func fireRunesUp() -> void:
	var allSpells = GameController.spells
	var fireSpells = allSpells.keys().filter(func(key): return key.contains("fire"))
	
	for key in fireSpells:
		if GameController.spells[key].damage != -2:
			GameController.spells[key].damage += 10

func redTearStone() -> void:
	#This has essentially ended up being a "do nothing" function
	pass

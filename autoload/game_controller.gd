extends Node

var playerHealth := 10
var maxHealth := 10
var playerBlock := 0
var playerGold := 0
var roomIndex := 0
var hand: Array[String] = []
var playerItems: Array[String] = []

var startingRunes: Array[String] = [
	"fire",
	"stone",
	"storm"
]

var unlockedRunes: Array[String] = [
	"fire",
	"stone",
	"storm"
]

var playerStartingDeck: Array[String] = [
	"fire", "fire", "fire", "fire",
	"stone", "stone", "stone", "stone",
	"storm", "storm"
]

var playerDeck: Array[String] = [
	"fire", "fire", "fire", "fire",
	"stone", "stone", "stone", "stone",
	"storm", "storm",
]

var runes ={
	"fire":{
		"sprite": preload("res://media/fireSymbol.png")
	},
	"stone":{
		"sprite": preload("res://media/stoneSymbol.png")
	},
	"storm":{
		"sprite": preload("res://media/stormSymbol.png")
	},
	"gold":{
		"sprite": preload("res://media/goldSymbol.png")
	},
	"death":{
		"sprite": preload("res://media/deathSymbol.png")
	}
}

'''
A note here we have kind of a fuck ass way of doing some of the odd effects
-1 being an indefinet amount of hits and -2 meaning it will calculate current gold as that value

might be better to do something like -1 and add an "instructions" field but aaah you know
'''

var spells = {
	"fire_fire":{
		"types":["damage"],
		"damage":5,
		"hits":1
	},
	"fire_stone":{
		"types":["damage", "block"],
		"damage":3,
		"block":3
	},
	"fire_storm":{
		"types":["damage"],
		"damage":1,
		"hits":4
	},
	"stone_stone":{
		"types":["block"],
		"block":5
	},
	"stone_storm":{
		"types":["effect"],
		"effect":"stun",
		"duration":1 #loses next action
		
	},
	"storm_storm":{
		"types":["damage"],
		"damage":2,
		"hits": -1 #gamble, each strike has a decreasing chance to hit
	},
	"gold_gold":{
		"types":["effect"],
		"effect":"gainGold",
		"amount":10,
	},
	"fire_gold":{
		"types":["damage"],
		"damage":-2,
		"hits":1
	},
	"gold_storm":{
		"types":["damage"],
		"damage":1,
		"hits":-2
	},
	"gold_stone":{
		"types":["block"],
		"block":-2,
	},
	"death_death":{
		"types":["effect"],
		"effect":"gamble", #70/30 chance instant death for enemy/you
		"amount":1000000000
	},
	"death_fire":{
		"types":["damage", "effect"],
		"effect":"delayedDamage",
		"damage":20,
		"hits":1,
		"delayedDamage":10
	},
	"death_stone":{#gain ludacris block in exchange for 3 life
		"types":["block", "effect"],
		"effect":"selfDamage",
		"block":100,
		"selfDamage":3
	}, 
	"death_storm":{#deal essentially 45 damage for 10 life
		"types":["damage", "effect"],
		"effect":"selfDamage",
		"damage":15,
		"hits":3,
		"selfDamage":10
	}, 
	"death_gold":{
		"types":["effect"],
		"effect":"bloodMoney", #2 health, 10 gold?
	},
}

var startingSpells = spells.duplicate()
var rooms = generateRooms()

@onready var canarySprite := preload("res://media/canary.png")
@onready var moleSprite := preload("res://media/mole.png")
@onready var frogSprite := preload("res://media/frog.png")
@onready var dragonSprite := preload("res://media/dragon.png")
@onready var oozeSprite := preload("res://media/ooze.png")

@onready var enemies = {
	"canary": {
		"name": "Canary",
		"health": 5,
		"sprite":canarySprite,
		"attacks": [
			{
				"type": "attack",
				"damage": 1
			},
			{
				"type": "attack",
				"damage": 2
			},
			{
				"type": "block",
				"block": 2
			},
		]
	},
	"frog": {
		"name": "Frog",
		"health": 15,
		"sprite":frogSprite,
		"attacks": [
			{
				"type": "attack",
				"damage": 5
			},
			{
				"type":"block",
				"block":15
			},
		]
	},
	"ooze": {
		"name": "Oooze",
		"health": 20,
		"sprite":oozeSprite,
		"attacks": [
			{
				"type": "block",
				"block": 10
			},
			{
				"type":"attack",
				"damage":6
			},
			{
				"type": "block",
				"block": 20
			},
			{
				"type":"attack",
				"damage":12
			},
		]
	},
	"mole": {
		"name": "Mole",
		"health": 15,
		"sprite":moleSprite,
		"attacks": [
			{
				"type":"attack",
				"damage":1
			},
			{
				"type": "attack",
				"damage": 2
			},
			{
				"type": "attack",
				"damage": 3
			},
			{
				"type": "attack",
				"damage": 5
			},
			{
				"type": "attack",
				"damage": 8
			},
			{
				"type": "attack",
				"damage": 13
			},
			{
				"type": "attack",
				"damage": 21
			},
			{
				"type": "attack",
				"damage": 34
			},
		]
	},
	"dragon": {
		"name": "Dragon",
		"health": 45,
		"sprite":dragonSprite,
		"attacks": [
			{
				"type":"attack",
				"damage":9
			},
			{
				"type": "attack",
				"damage": 5
			},
			{
				"type": "block",
				"damage": 15
			},
			{
				"type": "block",
				"damage": 10
			},
			{
				"type": "attack",
				"damage": 50
			},
		]
	}
}

func drawStartingHand() -> void:
	hand.clear()

	var combatDeckInstance = playerDeck.duplicate()
	combatDeckInstance.shuffle()

	var hand_size: int = min(5, combatDeckInstance.size())

	for i in range(hand_size):
		hand.append(combatDeckInstance.pop_back())
		
func drawNewHand() -> void:
	playerDeck.shuffle()
	drawStartingHand()
	
func addRune(runeType:String) -> void:
	unlockedRunes.append(runeType)

func playerTakeDamage(dmg:int):
	playerHealth -= dmg
	
func addRuneToDeck(rune:String) -> void:
	print('adding ' + rune + " to the deck")
	unlockedRunes.append(rune)
	playerDeck += [rune, rune, rune]
	print('new player deck: ')
	print(playerDeck)

func reset() -> void:
	playerDeck = playerStartingDeck
	unlockedRunes = startingRunes
	playerGold = 0
	playerHealth = 10
	roomIndex = 0
	maxHealth = 10
	playerItems = []
	spells = startingSpells

#testing an idea
func generateRooms() -> Array[Dictionary]:
	var generatedRooms: Array[Dictionary]
	
	#1
	generatedRooms.append({
		"type": "combat",
		"enemy": "canary"
	})
	
	generatedRooms.append({
		"type": "rune",
		"newRune": "gold"
	})
	
	generatedRooms.append({
		"type": "gold",
		"amount": randi_range(10,20)
	})
	
	generatedRooms.append(getRandomRoom())
	generatedRooms.append(getRandomRoom())
	
	generatedRooms.append({
		"type": "combat",
		"enemy": "frog"
	})
	
	generatedRooms.append(getRandomRoom())
	
	generatedRooms.append({
		"type": "combat",
		"enemy": "ooze"
	})
	
	generatedRooms.append(getRandomRoom())
	generatedRooms.append(getRandomRoom())
	
	generatedRooms.append({
		"type": "combat",
		"enemy": "mole"
	})
	
	generatedRooms.append(getRandomRoom())
	
	generatedRooms.append({
		"type": "rune",
		"newRune": "death"
	})
	
	generatedRooms.append(getRandomRoom())
	generatedRooms.append(getRandomRoom())
	
	generatedRooms.append({
		"type": "combat",
		"enemy": "dragon"
	})
	
	return generatedRooms

func getRandomRoom() -> Dictionary:
	var possibilities = ["gold", "shop"]
	
	var pick = possibilities.pick_random()
	if pick == "gold":
		return {"type":"gold", "amount": randi_range(10,20)}
	
	return {"type":"shop"}

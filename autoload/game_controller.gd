extends Node

var playerHealth := 10
var maxHealth := 10
var playerBlock := 0
var playerGold := 0
var roomIndex := 0

var hand: Array[String] = []

var unlockedRunes: Array[String] = [
	"fire",
	"stone",
	"storm"
]

var playerDeck: Array[String] = [
	"fire", "fire", "fire", "fire",
	"stone", "stone", "stone", "stone",
	"storm", "storm"
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
}

var rooms = [
	{
		"type": "combat",
		"enemy": "canary"
	},
	{
		"type": "gold",
		"amount": 10
	},
	{
		"type":"rune",
		"newRune":"gold"
	},
	{
		"type": "combat",
		"enemy": "mole"
	},
	{
		"type": "gold",
		"amount": 15
	},
	{
		"type": "combat",
		"enemy": "frog"
	},
	{
		"type":"rune",
		"newRune":"death"
	},
		{
		"type": "combat",
		"enemy": "dragon"
	},
]

@onready var canarySprite := preload("res://media/canary.png")
@onready var moleSprite := preload("res://media/mole.png")
@onready var frogSprite := preload("res://media/frog.png")

@onready var enemies = {
	"canary": {
		"name": "Canary",
		"health": 5,
		"sprite":canarySprite,
		"attacks": [
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
	"mole": {
		"name": "Mole",
		"health": 15,
		"sprite":moleSprite,
		"attacks": [
			{
				"type":"block",
				"block":6
			},
			{
				"type": "attack",
				"damage": 5
			}
		]
	},
	"frog": {
		"name": "Mole",
		"health": 15,
		"sprite":frogSprite,
		"attacks": [
			{
				"type":"block",
				"block":6
			},
			{
				"type": "attack",
				"damage": 5
			}
		]
	},
	"ooze": {
		"name": "Mole",
		"health": 15,
		"sprite":moleSprite,
		"attacks": [
			{
				"type":"block",
				"block":6
			},
			{
				"type": "attack",
				"damage": 5
			}
		]
	},
	"dragon": {
		"name": "Mole",
		"health": 30,
		"sprite":moleSprite,
		"attacks": [
			{
				"type":"attack",
				"damage":15
			},
			{
				"type": "attack",
				"damage": 5
			}
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
	playerDeck += [rune, rune, rune, rune]
	print('new player deck: ')
	print(playerDeck)

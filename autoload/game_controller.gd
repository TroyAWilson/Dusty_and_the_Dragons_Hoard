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
}

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
		"stun":1 #loses next action
	},
	"storm_storm":{
		"types":["damage"],
		"damage":2,
		"hits": -1 #gamble, each strike has a decreasing chance to hit
	}
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
		"type": "combat",
		"enemy": "mole"
	},
]

@onready var canarySprite := preload("res://media/canary.png")
@onready var moleSprite := preload("res://media/mole.png")

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
				"damage": 2
			},
		]
	},
	"mole": {
		"name": "Mole",
		"health": 5,
		"sprite":moleSprite,
		"attacks": [
			{
				"type": "attack",
				"damage": 2
			}
		]
	}
}


func drawStartingHand() -> void:
	hand.clear()

	var hand_size: int = min(5, playerDeck.size())

	for i in range(hand_size):
		hand.append(playerDeck.pop_back())
		
func drawNewHand() -> void:
	drawStartingHand()

extends Node

var playerHealth := 10
var maxHealth := 10
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

var rooms = [
	{
		"type": "combat",
		"enemy": "mole"
	},
	{
		"type": "gold",
		"amount": 10
	}
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
			}
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

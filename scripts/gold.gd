extends Node2D

var goldAmount: int = 0

@onready var amountLabel := $AmountLabel


func setup(amount: int) -> void:
	goldAmount = amount


func _ready() -> void:
	amountLabel.text = "+%d GOLD" % goldAmount

extends Node2D

signal addGold

var goldAmount: int = 0
var opened := false
@onready var amountLabel := $AmountLabel

func setup(amount: int) -> void:
	goldAmount = amount

func _ready() -> void:
	amountLabel.text = "[center]" + "+%d GOLD" % goldAmount

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gb_a") and not opened:
		opened = true
		#amountLabel.visible = true
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(amountLabel, "modulate:a", 1.0, 0.3)
		tween.tween_property(amountLabel, "position:y", amountLabel.position.y - 5, 0.3)
		
		GameController.playerGold += goldAmount
		addGold.emit()
		AudioController.playCoin()
		
	elif Input.is_action_just_pressed("gb_b"):
		print('I guess youre skipping, okay hate free money')

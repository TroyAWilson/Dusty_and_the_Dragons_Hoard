extends Node

var musicPlayer : AudioStreamPlayer

@onready var boop := preload("res://media/audio/synth.wav")
@onready var coin := preload("res://media/audio/pickupCoin.wav")
@onready var bkg := preload("res://media/audio/bkg.wav")
@onready var bkg2 := preload("res://media/audio/bkg2.wav")
@onready var hit := preload("res://media/audio/hitHurt.wav")
@onready var playerHit := preload("res://media/audio/playerHurt.wav")
@onready var pickupRune := preload("res://media/audio/pickupRune.wav")
@onready var gameOver := preload("res://media/audio/gameover.wav")
@onready var blipSelect := preload("res://media/audio/blipSelect.wav")
@onready var purchase := preload("res://media/audio/purchase.wav")
@onready var wompSynth := preload("res://media/audio/wompSynth.wav")
@onready var block := preload("res://media/audio/block.wav")
@onready var block2 := preload("res://media/audio/block2.wav")
@onready var stun := preload("res://media/audio/stun.wav")
@onready var win := preload("res://media/audio/win.wav")
@onready var intro := preload("res://media/audio/intro.wav")
@onready var intructions := preload("res://media/audio/instructions.wav")

func _ready() -> void:
	musicPlayer = AudioStreamPlayer.new()
	add_child(musicPlayer)

func playMusic(stream: AudioStream, volume:float = -25.0) -> AudioStreamPlayer:
	if musicPlayer.stream == stream and musicPlayer.playing:
		return
		
	musicPlayer.stream = stream
	musicPlayer.volume_db = volume
	musicPlayer.play()
	
	return musicPlayer

func playSFX(stream: AudioStream, volume:float = -25.0) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	player.bus = "SFX"
	
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()
	return player

func playBkg() -> AudioStreamPlayer:
	if bkg2 is AudioStreamWAV:
		bkg2.loop_mode = AudioStreamWAV.LOOP_FORWARD

	return playMusic(bkg2, -35.0)
	
func playWin() -> AudioStreamPlayer:
	if win is AudioStreamWAV:
		win.loop_mode = AudioStreamWAV.LOOP_FORWARD

	return playMusic(win, -35.0)
	
func playGameOver() -> AudioStreamPlayer:
	if gameOver is AudioStreamWAV:
		gameOver.loop_mode = AudioStreamWAV.LOOP_FORWARD

	return playMusic(gameOver, -35.0)
	
func playIntro() -> AudioStreamPlayer:
	if intro is AudioStreamWAV:
		intro.loop_mode = AudioStreamWAV.LOOP_FORWARD

	return playMusic(intro, -35.0)
	
func playInstructions() -> AudioStreamPlayer:
	if intructions is AudioStreamWAV:
		intructions.loop_mode = AudioStreamWAV.LOOP_FORWARD

	return playMusic(intructions, -35.0)
	
func playCoin() -> AudioStreamPlayer:
	return playSFX(coin)

func playBoop() -> AudioStreamPlayer:
	return playSFX(boop, -35.0)
	
func playHit() -> AudioStreamPlayer:
	return playSFX(hit, -35.0)
	
func playPlayerHit() -> AudioStreamPlayer:
	return playSFX(playerHit, -35.0)

func playPickupRune() -> AudioStreamPlayer:
	return playSFX(pickupRune, -35.0)
	
func playBlipSelect() -> AudioStreamPlayer:
	return playSFX(blipSelect, -35.0)
	
func playPurchase() -> AudioStreamPlayer:
	return playSFX(purchase, -35.0)
	
func playWompSynth() -> AudioStreamPlayer:
	return playSFX(wompSynth, -35.0)
	
func playBlock() -> AudioStreamPlayer:
	return playSFX(block, -35.0)
	
func playBlock2() -> AudioStreamPlayer:
	return playSFX(block2, -35.0)

func playStun() -> AudioStreamPlayer:
	return playSFX(stun, -35.0)

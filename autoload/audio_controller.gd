extends Node

var musicPlayer : AudioStreamPlayer

@onready var boop := preload("res://media/audio/synth.wav")
@onready var coin := preload("res://media/audio/pickupCoin.wav")

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
	
func playCoin() -> AudioStreamPlayer:
	return playSFX(coin)

func playBoop() -> AudioStreamPlayer:
	return playSFX(boop, -35.0)

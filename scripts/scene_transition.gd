extends CanvasLayer

@onready var fade := $ColorRect

var transitioning := false

const mainGame := "res://scenes/game.tscn"

func change_scene(path: String, duration := 0.5):
	if transitioning:
		return

	transitioning = true

	var tween = create_tween()

	# Fade out
	tween.tween_property(fade, "color:a", 1.0, duration)

	await tween.finished

	get_tree().change_scene_to_file(path)

	# Wait one frame so the new scene loads
	await get_tree().process_frame

	tween = create_tween()

	# Fade back in
	tween.tween_property(fade, "color:a", 0.0, duration)

	await tween.finished

	transitioning = false

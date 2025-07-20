extends VBoxContainer

@export_file("*.tscn") var game_scene: String

@onready var fade_out_timer: Timer = get_node("FadeOutTimer")
@onready var overlay: Node2D = get_node("Overlay")

func _on_start_button_pressed() -> void:
	fade_out_timer.start()
	for child in get_children():
		if child is BaseButton:
			child.disabled = true

func _process(delta: float) -> void:
	if not fade_out_timer.is_stopped():
		overlay.modulate.a = 1.0 - fade_out_timer.time_left / fade_out_timer.wait_time

func _on_fade_out_timer_timeout() -> void:
	get_tree().change_scene_to_file(self.game_scene)

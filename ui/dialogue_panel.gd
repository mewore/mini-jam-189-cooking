class_name DialoguePanel

extends HBoxContainer

@onready var speaker_avatar: TextureRect = get_node("SpeakerAvatar")
@onready var speaker_name_label: Label = get_node("TextContainer/Title/SpeakerName")
@onready var dialogue_label: Label = get_node("TextContainer/Dialogue")
@onready var time_label: Label = get_node("TextContainer/Title/TimeText")

@export var alien_avatar: Texture2D

@export var text_speed: float = 100
var displayed_char_count: float = 0

func get_speaker_name(speaker: E.Speaker) -> String:
	match speaker:
		E.Speaker.NARRATOR:
			return ""
		E.Speaker.ALIEN:
			return "G¬ort"
	return "<UNKNOWN>"

func get_speaker_avatar(speaker: E.Speaker) -> Texture2D:
	match speaker:
		E.Speaker.NARRATOR:
			return null
		E.Speaker.ALIEN:
			return alien_avatar
	return null

func display_text(speaker: E.Speaker, text: String) -> void:
	speaker_avatar.texture = get_speaker_avatar(speaker)
	speaker_name_label.text = get_speaker_name(speaker)
	dialogue_label.text = text
	displayed_char_count = 0

func _ready() -> void:
	display_text(E.Speaker.NARRATOR, "\n".join([
		"[Move] Arrow keys / D-Pad / Joystick",
		"[Interact / Confirm] Z / Space",
		"[Pause] Esc",
	]))

func _process(delta: float) -> void:
	displayed_char_count = min(displayed_char_count + text_speed * delta, dialogue_label.text.length())
	dialogue_label.visible_characters = round(displayed_char_count)

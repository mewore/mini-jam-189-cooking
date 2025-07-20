class_name DialoguePanel

extends HBoxContainer

@onready var speaker_avatar: TextureRect = get_node("SpeakerAvatar")
@onready var speaker_name_label: Label = get_node("TextContainer/Title/SpeakerName")
@onready var dialogue_label: Label = get_node("TextContainer/Content/Dialogue")
@onready var hint_label: Label = get_node("TextContainer/Content/Hint")
@onready var hint_label_animator: AnimationPlayer = get_node("TextContainer/Content/Hint/HintAnimator")
@onready var time_label: Label = get_node("TextContainer/Title/TimeText")

@export var alien_avatar: Texture2D

@export var text_speed: float = 100
var displayed_char_count: float = 0

var text_part_index: int = -1
var text_parts: PackedStringArray

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

func display_text(speaker: E.Speaker, text_parts: PackedStringArray) -> void:
	speaker_avatar.texture = get_speaker_avatar(speaker)
	speaker_name_label.text = get_speaker_name(speaker)
	self.text_parts = text_parts
	dialogue_label.text = text_parts[0]
	text_part_index = 0
	displayed_char_count = 0
	hint_label_animator.play()

func advance_text() -> void:
	if not dialogue_label.text.is_empty() and dialogue_label.visible_characters < dialogue_label.text.length():
		dialogue_label.visible_characters = dialogue_label.text.length()
		return

	text_part_index += 1
	if text_part_index < text_parts.size():
		dialogue_label.text = text_parts[text_part_index]
		displayed_char_count = 0
	else:
		text_parts = []
		text_part_index = -1
		speaker_avatar.texture = null
		speaker_name_label.text = ""
		dialogue_label.text = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not dialogue_label.text.is_empty():
		advance_text()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	display_text(E.Speaker.NARRATOR, ["\n".join([""])])
	display_text(E.Speaker.NARRATOR, ["wawa", "wawawawa", "wawaawwa\nwaa"])

func _process(delta: float) -> void:
	displayed_char_count = min(displayed_char_count + text_speed * delta, dialogue_label.text.length())
	dialogue_label.visible_characters = round(displayed_char_count)
	if dialogue_label.text.is_empty() and hint_label_animator.is_playing():
		hint_label_animator.stop()
		hint_label.visible = false
		

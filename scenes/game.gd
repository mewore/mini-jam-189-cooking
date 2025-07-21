class_name Game

extends Node2D

@export var ingredient_scene: PackedScene
@export var interaction_hint_opacity_damping: float = 1

@onready var alien := get_node("Am0gus")
@onready var player: Player = get_node("Player")
@onready var crates := get_node("Crates").get_children()
@onready var dialogue_panel: DialoguePanel = get_node("DialoguePanel")
@onready var cell_map: CellMap = get_node("CellMap")
@onready var interaction_hint: Node2D = get_node("InteractHint")
@onready var interaction_hint_opacity: float

var current_interaction_area: InteractionArea

var cosmetic_rng := RandomNumberGenerator.new()

enum GameState {
	EXPLORING,
	TAKING_ORDER,
	EXAMINING_CRATE,
	CHASING,
}

var game_state := GameState.EXPLORING

const ALIEN_LINES_INITIAL: PackedStringArray = [
	"Hi.",
	"This is your training. You will be learning to make meals for my species.\nWelcome to GLORT-cafe.",
	"You will be paid in… experience. :D",
	"Ok. Let’s get started.",
	"You’ll be making a glurger. It’s a 3 step process.",
	"Gather the ingredients. ???. Profit.",
	"I look forwards to trying your… cooking. Yes.",
]

const CRATE_EXAMINATION_OPTIONS: PackedStringArray =  [
	"Hmm...",
	"As a wise man once said... there is secret about crate.",
	"Did something move there?... Must've been the wind.",
	"*drools*",
]

func get_crate_examination_option() -> String:
	return CRATE_EXAMINATION_OPTIONS[cosmetic_rng.randi_range(0, CRATE_EXAMINATION_OPTIONS.size() - 1)]


func _on_interaction_area_entered(other_area: Area2D, area: InteractionArea) -> void:
	interaction_hint.global_position = area.hint_pos.global_position
	current_interaction_area = area


func _on_interaction_area_exited(other_area: Area2D, area: InteractionArea) -> void:
	current_interaction_area = null


func _ready() -> void:
	cosmetic_rng.randomize()
	for crate in crates:
		cell_map.add_node_collision(crate)
	cell_map.add_node_collision(alien)
	for node in get_node("InteractionAreas").get_children():
		var interaction_area: InteractionArea = node
		interaction_area.area_entered.connect(_on_interaction_area_entered.bind(interaction_area))
		interaction_area.area_exited.connect(_on_interaction_area_exited.bind(interaction_area))
	interaction_hint_opacity = interaction_hint.modulate.a
	interaction_hint.modulate.a = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") and current_interaction_area != null and game_state == GameState.EXPLORING:
		var speaker := current_interaction_area.speaker
		match speaker:
			E.Speaker.ALIEN:
				dialogue_panel.display_text(speaker, ALIEN_LINES_INITIAL)
				game_state = GameState.TAKING_ORDER
				player.frozen = true
			E.Speaker.CRATE:
				dialogue_panel.display_text(speaker, [get_crate_examination_option()])
				game_state = GameState.EXAMINING_CRATE
				player.frozen = true
			_:
				print("Cannot handle speaker: ", speaker)


func _process(_delta: float) -> void:
	var interaction_hint_visible := game_state in [GameState.EXPLORING, GameState.EXAMINING_CRATE] and current_interaction_area != null
	var target_opacity := interaction_hint_opacity if interaction_hint_visible else 0.0
	interaction_hint.modulate.a += (target_opacity - interaction_hint.modulate.a) / (interaction_hint_opacity_damping + 1.0)


func _on_dialogue_panel_dialogue_over() -> void:
	print("Dialogue over")
	match game_state:
		GameState.EXPLORING:
			print("eeEEE?!")
		GameState.TAKING_ORDER:
			game_state = GameState.EXPLORING
			player.frozen = false
		GameState.EXAMINING_CRATE:
			game_state = GameState.EXPLORING
			player.frozen = false
		GameState.CHASING:
			print("eeEEE?!")

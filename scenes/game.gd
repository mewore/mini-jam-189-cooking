class_name Game

extends Node2D

@export var ingredient_scene: PackedScene
@export var interaction_hint_opacity_damping: float = 1

@onready var alien := get_node("Am0gus")
@onready var player := get_node("Player")
@onready var crates := get_node("Crates").get_children()
@onready var dialogue_panel := get_node("DialoguePanel")
@onready var cell_map: CellMap = get_node("CellMap")
@onready var interaction_hint: Node2D = get_node("InteractHint")
@onready var interaction_hint_opacity: float

var interaction_hint_visible := false

enum GameState {
	EXPLORING,
	TALKING,
	CHASING,
}

func _on_interaction_area_entered(other_area: Area2D, area: InteractionArea) -> void:
	interaction_hint_visible = true
	interaction_hint.global_position = area.hint_pos.global_position

func _on_interaction_area_exited(other_area: Area2D, area: InteractionArea) -> void:
	interaction_hint_visible = false

func _ready() -> void:
	for crate in crates:
		cell_map.add_node_collision(crate)
	cell_map.add_node_collision(alien)
	for node in get_node("InteractionAreas").get_children():
		var interaction_area: InteractionArea = node
		interaction_area.area_entered.connect(_on_interaction_area_entered.bind(interaction_area))
		interaction_area.area_exited.connect(_on_interaction_area_exited.bind(interaction_area))
	interaction_hint_opacity = interaction_hint.modulate.a
	interaction_hint.modulate.a = 0

func _process(_delta: float) -> void:
	var target_opacity := interaction_hint_opacity if interaction_hint_visible else 0.0
	interaction_hint.modulate.a += (target_opacity - interaction_hint.modulate.a) / (interaction_hint_opacity_damping + 1.0)

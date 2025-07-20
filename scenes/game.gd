class_name Game

extends Node2D

@export var ingredient_scene: PackedScene

@onready var alien := get_node("Am0gus")
@onready var player := get_node("Player")
@onready var crates := get_node("Crates").get_children()
@onready var dialogue_panel := get_node("DialoguePanel")

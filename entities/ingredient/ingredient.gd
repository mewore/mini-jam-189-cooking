class_name Ingredient

extends Node2D

enum IngredientAi {
	PANIC,
	TAUNT,
	RUN,
}

@export var ai := IngredientAi.PANIC

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

func decide_direction(
	available_directions: PackedByteArray,
	distance_from_player: PackedInt32Array,
	last_direction: Direction,
) -> Direction:
	
	return Direction.UP

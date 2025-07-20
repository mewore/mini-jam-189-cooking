class_name Player

extends Node2D

@export var DASH_STEPS := 10
@export var SPEED: float = 8
@export var DASH_SPEED: float = 24
@export_node_path("CellMap") var cell_map: NodePath

@onready var sprite_root: SpriteRoot = get_node("SpriteRoot")
@onready var walking_sound_player: AudioStreamPlayer = get_node("WalkingSoundPlayer")
@onready var dash_timer: Timer = get_node("Dash")
@onready var dash_cooldown_timer: Timer = get_node("DashCooldown")
@onready var dash_input_linger_timer: Timer = get_node("DashInputLinger")
@onready var dash_particles: CPUParticles2D = get_node("SpriteRoot/DashParticles")

var nearby_area: Node
var cell_map_node: CellMap

var direction_priority := [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
]

const DIRECTION_INPUTS := {
	Vector2i.LEFT: "move_left",
	Vector2i.RIGHT: "move_right",
	Vector2i.UP: "move_up",
	Vector2i.DOWN: "move_down",
}

var current_cell: Vector2i
var move_direction := Vector2i.ZERO
var latest_direction := Vector2i.ZERO
var step_queue := []
var steps_remaining := 0
var step_completion := 0.0

var last_requested_dash_at: int = -999999999


func _ready() -> void:
	if cell_map:
		cell_map_node = get_node(cell_map)
	current_cell = cell_map_node.get_node_cell(self) if cell_map_node else Vector2i.ZERO


func is_direction_possible(direction: Vector2i) -> bool:
	return cell_map_node.is_cell_free(current_cell + move_direction + direction) if cell_map_node else true


func _unhandled_input(event: InputEvent) -> void:
	var dir_index_to_hoist := -1
	for dir_index in range(direction_priority.size()):
		var direction: Vector2i = direction_priority[dir_index]
		var input_name: StringName = DIRECTION_INPUTS.get(direction)
		if event.is_action_pressed(input_name) and event.get_action_strength(input_name) >= 1.0:
			dir_index_to_hoist = dir_index
			if steps_remaining > 0:
				step_queue.append(direction)
			break
	if dir_index_to_hoist >= 0:
		direction_priority.insert(0, direction_priority.pop_at(dir_index_to_hoist))
	if event.is_action("dash"):
		dash_input_linger_timer.start()


func pick_move_direction() -> Vector2i:
	var input_dir = Vector2i.ZERO
	while not step_queue.is_empty() and not is_direction_possible(step_queue.front()):
		step_queue.pop_front()

	if not step_queue.is_empty():
		return step_queue.pop_front()
		
	for dir_index in range(direction_priority.size()):
		var direction: Vector2i = direction_priority[dir_index]
		var input_name: StringName = DIRECTION_INPUTS.get(direction)
		if Input.is_action_pressed(input_name) and is_direction_possible(direction):
			return direction
			
	if steps_remaining > 0 and is_direction_possible(latest_direction):
		return latest_direction
	
	return Vector2i.ZERO


func _process(_delta: float) -> void:
	if not move_direction:
		var input_dir := pick_move_direction()
		
		if input_dir != Vector2i.ZERO:
			move_direction = input_dir
			latest_direction = move_direction
			steps_remaining = max(steps_remaining, 1)
			step_completion = 0
	
	if not dash_input_linger_timer.is_stopped() and latest_direction \
		and dash_cooldown_timer.is_stopped() \
		and is_direction_possible(latest_direction):
			move_direction = latest_direction
			latest_direction = move_direction
			steps_remaining = DASH_STEPS
			step_completion = 0
			dash_input_linger_timer.stop()
			dash_cooldown_timer.start()
			dash_timer.start()
	
	walking_sound_player.playing = steps_remaining > 0
	sprite_root.shaking = steps_remaining > 0
	dash_particles.emitting = not dash_timer.is_stopped()


func _physics_process(delta: float) -> void:
	if steps_remaining > 0:
		var dash_speed_coeff := 0.0 if dash_timer.is_stopped() else dash_timer.time_left / dash_timer.wait_time
		var speed := SPEED * (1.0 - dash_speed_coeff) + DASH_SPEED * dash_speed_coeff
		step_completion = min(step_completion + delta * speed, 1.0)
		if cell_map_node:
			position = cell_map_node.interpolate_pos(current_cell, move_direction, step_completion)
		if step_completion >= 1.0:
			current_cell += move_direction
			move_direction = Vector2i.ZERO
			steps_remaining -= 1
			step_completion = 0


func _on_interaction_detector_area_entered(area: Area2D) -> void:
	nearby_area = area


func _on_interaction_detector_area_exited(area: Area2D) -> void:
	nearby_area = null

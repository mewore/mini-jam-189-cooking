class_name Player

extends Node2D

@export var top_left: Node2D
@export var bottom_right: Node2D
@export var CELL_SIZE := 8
@export var DASH_STEPS := 10
@export var SPEED: float = 8
@export var DASH_SPEED: float = 24
@export_node_path("TileMapLayer") var map: NodePath

@onready var sprite_root: SpriteRoot = get_node("SpriteRoot")
@onready var walking_sound_player: AudioStreamPlayer = get_node("WalkingSoundPlayer")
@onready var dash_timer: Timer = get_node("Dash")
@onready var dash_cooldown_timer: Timer = get_node("DashCooldown")
@onready var dash_input_linger_timer: Timer = get_node("DashInputLinger")
@onready var dash_particles: CPUParticles2D = get_node("SpriteRoot/DashParticles")

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

var top_left_cell := Vector2i.MIN
var bottom_right_cell := Vector2i.MAX

var map_node: TileMapLayer

var last_requested_dash_at: int = -999999999

func _ready() -> void:
	current_cell = (position / CELL_SIZE).round()
	if top_left:
		top_left_cell = (get_parent().to_local(top_left.global_position) / CELL_SIZE).round()
	if bottom_right:
		bottom_right_cell = (get_parent().to_local(bottom_right.global_position) / CELL_SIZE).round()
	if map:
		map_node = get_node(map)

func direction_is_possible(direction: Vector2i) -> bool:
	var target := current_cell + direction
	if map_node and map_node.get_cell_source_id(target) >= 0:
		return false
	return target.x >= top_left_cell.x and target.x < bottom_right_cell.x \
		and target.y >= top_left_cell.y and target.y < bottom_right_cell.y

func _unhandled_input(event: InputEvent) -> void:
	var dir_index_to_hoist := -1
	for dir_index in range(direction_priority.size()):
		var direction: Vector2i = direction_priority[dir_index]
		var input_name: StringName = DIRECTION_INPUTS.get(direction)
		if event.is_action_pressed(input_name):
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
	while not step_queue.is_empty() and not direction_is_possible(step_queue.front()):
		step_queue.pop_front()

	if not step_queue.is_empty():
		return step_queue.pop_front()
		
	for dir_index in range(direction_priority.size()):
		var direction: Vector2i = direction_priority[dir_index]
		var input_name: StringName = DIRECTION_INPUTS.get(direction)
		if Input.is_action_pressed(input_name) and direction_is_possible(direction):
			return direction
			
	if steps_remaining > 0 and direction_is_possible(latest_direction):
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
		and direction_is_possible(latest_direction):
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
		position = Vector2(current_cell) * CELL_SIZE + \
			step_completion * CELL_SIZE * move_direction
		if step_completion >= 1.0:
			current_cell += move_direction
			move_direction = Vector2i.ZERO
			print("Completed step ", steps_remaining, " -> ", steps_remaining - 1)
			steps_remaining -= 1
			step_completion = 0

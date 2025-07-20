class_name Player

extends Node2D

@export var top_left: Node2D
@export var bottom_right: Node2D
@export var CELL_SIZE := 8
@export var SPEED := 1.0

var current_cell: Vector2i
var move_direction := Vector2i.ZERO
var steps_remaining := 0
var step_completion := 0.0

var top_left_cell := Vector2i.MIN
var bottom_right_cell := Vector2i.MAX

func _ready() -> void:
	self.current_cell = (position / CELL_SIZE).round()
	if self.top_left:
		self.top_left_cell = (to_local(self.top_left.global_position) / CELL_SIZE).round()
	if self.bottom_right:
		self.bottom_right_cell = (to_local(self.bottom_right.global_position) / CELL_SIZE).round()

func direction_is_possible(direction: Vector2i) -> bool:
	var x := current_cell.x + direction.x
	var y := current_cell.y + direction.y
	return x >= self.top_left_cell.x and x < self.bottom_right_cell.x \
		and y >= self.top_left_cell.y and y < self.bottom_right_cell.y

func _process(delta: float) -> void:
	if self.steps_remaining <= 0:
		var input_dir = Vector2i.ZERO
		if Input.is_action_pressed("move_left"):
			input_dir = Vector2i.LEFT
		elif Input.is_action_pressed("move_right"):
			input_dir = Vector2i.RIGHT
		elif Input.is_action_pressed("move_up"):
			input_dir = Vector2i.UP
		elif Input.is_action_pressed("move_down"):
			input_dir = Vector2i.DOWN
		if input_dir != Vector2i.ZERO and direction_is_possible(input_dir):
			self.move_direction = input_dir
			self.steps_remaining = 1
			self.step_completion = 0

func _physics_process(delta: float) -> void:
	if self.steps_remaining > 0:
		self.step_completion = min(self.step_completion + delta * SPEED, 1.0)
		self.position = Vector2(self.current_cell) * CELL_SIZE + \
			self.step_completion * CELL_SIZE * self.move_direction
		if self.step_completion >= 1.0:
			self.current_cell += self.move_direction
			self.move_direction = Vector2i.ZERO
			self.steps_remaining -= 1

class_name CellMap

extends Node2D

@export var CELL_SIZE := 8
@export var top_left: Node2D
@export var bottom_right: Node2D
@export_node_path("TileMapLayer") var map: NodePath

var top_left_cell := Vector2i.MIN
var bottom_right_cell := Vector2i.MAX

var map_node: TileMapLayer

var collision_cells := {}


func get_node_cell(node: Node2D) -> Vector2i:
	return (node.global_position / CELL_SIZE).round()


func add_node_collision(node: Node2D) -> void:
	var cell := get_node_cell(node)
	collision_cells[cell] = true


func _ready() -> void:
	if top_left:
		top_left_cell = (top_left.global_position / CELL_SIZE).round()
	if bottom_right:
		bottom_right_cell = (bottom_right.global_position / CELL_SIZE).round()
	if map:
		map_node = get_node(map)


func interpolate_pos(cell: Vector2i, direction: Vector2i, amount: float) -> Vector2:
	return to_global((Vector2(cell) + direction * amount) * CELL_SIZE)


func is_cell_free(cell: Vector2i) -> bool:
	if map_node and map_node.get_cell_source_id(cell) >= 0:
		return false
	if collision_cells.has(cell):
		return false
	return cell.x >= top_left_cell.x and cell.x < bottom_right_cell.x \
		and cell.y >= top_left_cell.y and cell.y < bottom_right_cell.y

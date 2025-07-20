class_name SpriteRoot

extends Node2D

@export var shake_amplitude := TAU / 25
@export var shake_speed := 20.0
@export var damping := 1.0

var current_amplitude := 0.0

var shaking := false
var total_time := 0.0

func _process(delta: float) -> void:
	self.total_time += delta
	var target_amplitude := self.shake_amplitude if self.shaking else 0.0
	self.current_amplitude = self.current_amplitude + \
		(target_amplitude - self.current_amplitude) / (self.damping + 1)
	if current_amplitude < 0.00001 or not self.shaking:
		rotation = 0.0
	else:
		rotation = sin(self.total_time * shake_speed) * shake_amplitude

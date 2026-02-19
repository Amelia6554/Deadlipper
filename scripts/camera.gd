extends Camera2D

@export var target: Node2D
var follow := false

func _process(delta):
	if follow and target:
		global_position = target.global_position

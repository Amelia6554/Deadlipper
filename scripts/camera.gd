extends Camera2D

var target: Node2D = null
var follow: bool = false 

func _physics_process(delta):
	if follow and target != null:
		# Kamera podąża za graczem 
		global_position = target.global_position

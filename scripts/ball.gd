extends CharacterBody2D

@export var gravity: float = 1200.0
var is_dropped := false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_dropped = true

func _physics_process(delta: float) -> void:
	
	if not is_dropped:
		# Podążanie za kursorem
		global_position = get_global_mouse_position()
		velocity = Vector2.ZERO
	else:
		# Spadanie
		if not is_on_floor():
			velocity.y += gravity * delta
		
		move_and_slide()

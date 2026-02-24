extends Trap

@export var wind_strength_multiplier: float = 10.0 

func _init():
	trap_name = "Wiatrak"
	cost = 150
	damage = 0
	

func _physics_process(_delta):
	if not is_active:
		return
	
	# Pobieramy wszystkie obiekty, które są w polu wiatru
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player" and body is RigidBody2D:
			apply_effect(body)
			

func apply_effect(body):
	if body is RigidBody2D:
		var wind_dir = -global_transform.y 
		
		var to_body = body.global_position - global_position
		var distance_along_wind = to_body.dot(wind_dir)
		var max_range = get_shape_height()
		
		if distance_along_wind < 0 or distance_along_wind > max_range:
			return
			
		var force_factor = clamp(1.0 - (distance_along_wind / max_range), 0.0, 1.0)
		force_factor = pow(force_factor, 1.5)

		var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		
		# push_force uwzględnia masę kulki, więc zawsze zadziała tak samo
		var push_force = gravity * body.mass * wind_strength_multiplier
		
		body.apply_central_force(wind_dir * push_force * force_factor)
		
func get_shape_height() -> float:
	var collision_shape = $CollisionShape2D
	var shape = collision_shape.shape
	
	if shape is RectangleShape2D:
		return shape.size.y
	elif shape is CapsuleShape2D:
		return shape.height
	elif shape is CircleShape2D:
		return shape.radius * 2
	
	return 100.0 # Wartość awaryjna

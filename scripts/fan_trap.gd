extends Trap # Dziedziczymy trap_name, cost, is_active itp.

@export var wind_force: float = 1000.0

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
		
		# 1. Obliczamy siłę potrzebną do uniesienia kulki (przeciw grawitacji)
		# gravity_scale * masa * grawitacja projektu
		var gravity_force = body.gravity_scale * body.mass * ProjectSettings.get_setting("physics/2d/default_gravity")
		
		# 2. Dodajemy naszą siłę wiatru
		var total_force = (wind_dir * wind_force) + (Vector2.UP * gravity_force)
		
		body.apply_central_force(total_force)

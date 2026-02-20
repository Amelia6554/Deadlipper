extends Trap # Dziedziczymy trap_name, cost, is_active itp.

@export var wind_force: float = 10000.0
@export var wind_direction: Vector2 = Vector2.UP

func _ready():
	trap_name = "Wiatrak"
	cost = 150
	damage = 0 # Wiatrak zazwyczaj nie zadaje obrażeń
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(body):
	#if not is_active:
		#return
		#
	## Pobieramy wszystkie obiekty wewnątrz Area2D wiatraka
	#var bodies = get_overlapping_bodies()
	#for body in bodies:
	if body.name == "Player":
		apply_effect(body)

# Nadpisujemy apply_effect, żeby zamiast zadawać HP, dodawał siłę fizyczną
func apply_effect(body):
	if body is RigidBody2D:
		var force = wind_direction.normalized() * wind_force
		body.apply_central_force(force)

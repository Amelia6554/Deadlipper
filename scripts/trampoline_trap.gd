extends Trap 

@export var bounce_force: float = 800.0

func _init():
	trap_name = "Trampolina"
	cost = 100
	damage = 0

func _ready():
	# Podłączamy wykrywanie wejścia
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		trigger_trap(body)

# Nadpisujemy funkcję efektu
func apply_effect(body: Node2D):
	if body is RigidBody2D:
		print("Trampolina wystrzeliwuje piłkę!")
		# Zerujemy prędkość pionową, żeby skok zawsze był tak samo silny
		body.linear_velocity.y = 0
		# Nadajemy impuls w górę (względem rotacji trampoliny!)
		# transform.y to wektor pokazujący "dół" trampoliny, więc używamy minus transform.y
		body.apply_central_impulse(-transform.y * bounce_force)

extends Trap # Dziedziczymy wszystkie zmienne (cost, damage itp.) z klasy Trap!

func _ready():
	# Tu ustawiamy statystyki specyficzne dla kolców
	trap_name = "Kolce"
	cost = 100
	damage = 25
	
	# Podłączamy wbudowany sygnał Godota, który wykrywa wejście obiektu
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Sprawdzamy, czy to co wpadło w kolce, to nasza piłka
	if body.name == "Player": 
		trigger_trap(body) # Wywołujemy funkcję z klasy bazowej

# Tutaj NADPISUJEMY pustą funkcję z klasy bazowej, żeby dać kolcom unikalny efekt
func apply_effect(body):
	print("Auć! Piłka nadziała się na kolce i traci ", damage, " HP!")
	if body.has_method("take_damage"):
		body.take_damage(damage) # Zadajemy obrażenia zdefiniowane w pułapce

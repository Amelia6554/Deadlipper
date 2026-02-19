extends Node2D

@export var player_money: int = 500
@export var spikes_scene: PackedScene

# Zmienna przechowująca scenę aktualnie wybranej pułapki
var selected_trap_scene: PackedScene = null

var can_place_traps: bool = true

func _unhandled_input(event):
	if can_place_traps == false:
		return
	# Sprawdzamy, czy gracz kliknął lewym przyciskiem myszy na mapie
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_trap_scene != null:
			place_trap(get_global_mouse_position())

# Funkcja wywoływana przez przycisk w GUI
func select_spikes():
	selected_trap_scene = spikes_scene
	print("Wybrano Kolce do postawienia!")

func place_trap(click_position: Vector2):
	# 1. Najpierw sprawdzamy, CO jest pod myszką (Zanim wydamy pieniądze!)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(click_position - Vector2(0, 100), click_position + Vector2(0, 100))
	
	# Opcjonalnie: query.collision_mask = 1  <-- Tutaj możesz podać numer warstwy Twojej mapy
	
	var result = space_state.intersect_ray(query)
	
	# 2. JEŚLI NIC NIE TRAFILIŚMY (powietrze), przerywamy funkcję
	if not result:
		print("Nie można postawić pułapki w powietrzu!")
		return
	
	# 1. Tworzymy tymczasową instancję, żeby odczytać jej koszt
	var trap_instance = selected_trap_scene.instantiate() as Trap
	
	# 2. Sprawdzamy, czy stać nas na pułapkę
	if player_money >= trap_instance.cost:
		# Pobieramy opłatę
		player_money -= trap_instance.cost
		print("Kupiono pułapkę! Zostało pieniędzy: ", player_money)
		
		if result:
			# Jeśli promień w coś trafił (np. w podłoże), przyklejamy pułapkę 
			# do punktu styku
			trap_instance.global_position = result.position
			
			var surface_normal = result.normal
			# Obracamy pułapkę! result.normal.angle() podaje kąt pochylenia, 
			# a dodanie PI / 2.0 (czyli 90 stopni) sprawia, że pułapka stoi 
			# prosto względem podłoża.
			trap_instance.rotation = surface_normal.angle() + (PI / 2.0)
			add_child(trap_instance)
		else:
			trap_instance.queue_free()
			
	else:
		# Jeśli nas nie stać, usuwamy stworzoną przed chwilą instancję
		print("Za mało pieniędzy! Brakuje: ", trap_instance.cost - player_money)
		trap_instance.queue_free()


func _on_btn_spikes_pressed() -> void:
	pass # Replace with function body.

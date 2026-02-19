extends Node2D

@export var player_money: int = 500
@export var spikes_scene: PackedScene

# Zmienna przechowująca scenę aktualnie wybranej pułapki
var selected_trap_scene: PackedScene = null

func _unhandled_input(event):
	# Sprawdzamy, czy gracz kliknął lewym przyciskiem myszy na mapie
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_trap_scene != null:
			place_trap(get_global_mouse_position())

# Funkcja wywoływana przez przycisk w GUI
func select_spikes():
	selected_trap_scene = spikes_scene
	print("Wybrano Kolce do postawienia!")

func place_trap(click_position: Vector2):
	# 1. Tworzymy tymczasową instancję, żeby odczytać jej koszt
	var trap_instance = selected_trap_scene.instantiate() as Trap
	
	# 2. Sprawdzamy, czy stać nas na pułapkę
	if player_money >= trap_instance.cost:
		# Pobieramy opłatę
		player_money -= trap_instance.cost
		print("Kupiono pułapkę! Zostało pieniędzy: ", player_money)
		
		# 3. Ustawiamy pozycję na miejsce kliknięcia i dodajemy do mapy
		trap_instance.global_position = click_position
		add_child(trap_instance)
		
		# (Opcjonalnie) Odznaczamy pułapkę, żeby nie stawiać jej w nieskończoność:
		# selected_trap_scene = null 
	else:
		# Jeśli nas nie stać, usuwamy stworzoną przed chwilą instancję
		print("Za mało pieniędzy! Brakuje: ", trap_instance.cost - player_money)
		trap_instance.queue_free()


func _on_btn_spikes_pressed() -> void:
	pass # Replace with function body.

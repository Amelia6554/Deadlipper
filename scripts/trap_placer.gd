extends Node2D

@export var player_money: int = 500
@onready var preview_sprite: Sprite2D = $PreviewSprite
@export var money_label: Label

#---traps-------------------------------
@export var spikes_scene: PackedScene
@export var trampoline_scene: PackedScene

# Zmienna przechowująca scenę aktualnie wybranej pułapki
var selected_trap_scene: PackedScene = null

var can_place_traps: bool = true
var place_margin = 50

func _process(_delta):
	# Jeśli nie mamy wybranej pułapki lub gra wystartowała - chowamy podgląd
	if not can_place_traps or selected_trap_scene == null:
		preview_sprite.visible = false
		return

	update_preview()
	
func _ready():
	# Wywołujemy aktualizację napisu na samym starcie
	update_money_display()

func update_money_display():
	if money_label != null:
		money_label.text = "Kasa: " + str(player_money) + "$"
	
func update_preview():
	preview_sprite.visible = true
	var mouse_pos = get_global_mouse_position()
	
	# Strzelamy promieniem tak samo jak przy stawianiu
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(mouse_pos - Vector2(0, place_margin), 
	mouse_pos + Vector2(0, place_margin))
	var result = space_state.intersect_ray(query)
	
	if result:
		# Ustawiamy pozycję i rotację podglądu
		preview_sprite.global_position = result.position
		preview_sprite.rotation = result.normal.angle() + (PI / 2.0)
		
		# Sprawdzamy, czy nas stać - jeśli nie, podświetlamy na czerwono
		var temp_trap = selected_trap_scene.instantiate() as Trap
		if player_money >= temp_trap.cost:
			preview_sprite.modulate = Color(1, 1, 1, 0.5) # Normalny półprzezroczysty
		else:
			preview_sprite.modulate = Color(1, 0, 0, 0.5) # Czerwony (brak kasy)
		temp_trap.queue_free()
	else:
		# Jeśli myszka jest w powietrzu
		preview_sprite.global_position = mouse_pos
		preview_sprite.rotation = 0
		preview_sprite.modulate = Color(1, 0, 0, 0.5) # Czerwony (nie można tu budować)

func _unhandled_input(event):
	if can_place_traps == false:
		return
	# Sprawdzamy, czy gracz kliknął lewym przyciskiem myszy na mapie
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_trap_scene != null:
			place_trap(get_global_mouse_position())

func place_trap(click_position: Vector2):
	# 1. Najpierw sprawdzamy, CO jest pod myszką (Zanim wydamy pieniądze!)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(click_position - Vector2(0, place_margin),
	 click_position + Vector2(0, place_margin))
	
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
		update_money_display()
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
	
#------------------Traps--------------------

# Funkcja wywoływana przez przycisk w GUI
func select_spikes():
	if not can_place_traps: return
	selected_trap_scene = spikes_scene
	print("Wybrano Kolce do postawienia!")
	
	# Ustawiamy teksturę podglądu na teksturę kolców
	var temp_instance = spikes_scene.instantiate()
	# Szukamy Sprite2D wewnątrz sceny kolców (zakładam, że tam jest)
	var spike_sprite = temp_instance.get_node("Sprite2D") as Sprite2D
	preview_sprite.texture = spike_sprite.texture
	temp_instance.queue_free()
	
func select_trampoline():
	if not can_place_traps: return
	selected_trap_scene = trampoline_scene
	
	# Aktualizujemy ikonkę podglądu
	var temp = trampoline_scene.instantiate()
	preview_sprite.texture = temp.get_node("Sprite2D").texture
	temp.queue_free()

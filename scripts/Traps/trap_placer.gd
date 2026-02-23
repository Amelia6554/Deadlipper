extends Node2D

@export var player_money: int = 10000
@onready var preview_sprite: Sprite2D = $PreviewSprite
@export var money_label: Label
@export var hammer_icon: Texture2D

#---traps-------------------------------
@export var spikes_scene: PackedScene
@export var trampoline_scene: PackedScene
@export var fan_scene: PackedScene

# Zmienna przechowująca scenę aktualnie wybranej pułapki
var selected_trap_scene: PackedScene = null

#setup
var place_margin = 50
var colorRed = Color(1, 0, 0, 0.5)

#states
var can_place_traps: bool = true
var is_destroy_mode: bool = false
var highlighted_trap: Trap = null

func select_destroy_tool():
	is_destroy_mode = true
	selected_trap_scene = null
	if hammer_icon:
		preview_sprite.texture = hammer_icon
		preview_sprite.scale = Vector2(1, 1) # Reset skali, by młotek nie był gigantyczny
		preview_sprite.modulate = Color(1, 1, 1, 0.8) # Prawie pełna widoczność
		preview_sprite.visible = true
	print("Tryb usuwania aktywny")

func _process(_delta):
	if not can_place_traps or (selected_trap_scene == null and not is_destroy_mode):
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
	if is_destroy_mode:
		# Młotek po prostu podąża za myszką
		preview_sprite.global_position = mouse_pos
		preview_sprite.rotation = 0
		
		var current_trap = get_trap_under_mouse()
		
		if current_trap != highlighted_trap:
			# Przywróć kolor poprzedniej (jeśli była)
			if highlighted_trap != null:
				highlighted_trap.modulate = Color(1, 1, 1) 
			
			# Podświetl nową
			highlighted_trap = current_trap
			if highlighted_trap != null:
				highlighted_trap.modulate = colorRed # Czerwony
	else:
		if highlighted_trap != null:
			highlighted_trap.modulate = Color(1, 1, 1)
			highlighted_trap = null
		var result = get_surface_at_mouse(mouse_pos)

		if result:
			# Ustawiamy pozycję i rotację podglądu
			preview_sprite.global_position = result.position
			preview_sprite.rotation = result.normal.angle() + (PI / 2.0)
			
			# Sprawdzamy, czy nas stać - jeśli nie, podświetlamy na czerwono
			var trap_cost = get_trap_cost(selected_trap_scene)
		
			if player_money >= trap_cost:
				preview_sprite.modulate = Color(1, 1, 1, 0.5)
			else:
				preview_sprite.modulate = colorRed
		else:
			# Jeśli myszka jest w powietrzu
			preview_sprite.global_position = mouse_pos
			preview_sprite.rotation = 0
			preview_sprite.modulate = colorRed# Czerwony (nie można tu budować)
		
func get_trap_cost(scene: PackedScene) -> int:
	var state = scene.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == "cost":
			return state.get_node_property_value(0, i)
	return 0 

func get_trap_under_mouse() -> Trap:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for res in results:
		if res.collider is Trap:
			return res.collider
	return null

func is_hovering_trap() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for res in results:
		if res.collider is Trap:
			return true
	return false

func _unhandled_input(event):
	if not can_place_traps:
		return
	# Sprawdzamy, czy gracz kliknął lewym przyciskiem myszy na mapie
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_destroy_mode:
			destroy_trap_at_mouse()
		if selected_trap_scene != null:
			place_trap(get_global_mouse_position())

func activate_traps():
	for child in get_children():
		if child is Trap:
			child.is_active = true
			print("Pułapka ", child.trap_name, " została aktywowana!")
			
			
func deactivate_traps():
	for child in get_children():
		if child is Trap:
			child.is_active = false
			print("Pułapka ", child.trap_name, " została deaktywowana!")

func get_surface_at_mouse(mouse_pos):
	var space_state = get_world_2d().direct_space_state
	
	# 1. Sprawdzamy, czy myszka nie jest "wmurowana" w ścianę
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.position = mouse_pos
	point_query.collide_with_areas = false
	if not space_state.intersect_point(point_query).is_empty():
		return null # Nie pozwalamy budować "wewnątrz"
	
	var closest_result = null
	var min_distance = INF
	
	# 2. Strzelamy 8 promieniami OD MYSZKI na zewnątrz
	# To znajdzie ścianę, która jest najbliżej Twojego kursora
	var directions = [
		Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
		Vector2(1, 1).normalized(), Vector2(1, -1).normalized(),
		Vector2(-1, 1).normalized(), Vector2(-1, -1).normalized()
	]
	
	for dir in directions:
		# Strzelamy od myszki w danym kierunku na odległość place_margin
		var ray_query = PhysicsRayQueryParameters2D.create(mouse_pos, mouse_pos + (dir * place_margin))
		var res = space_state.intersect_ray(ray_query)
		
		if res:
			var dist = mouse_pos.distance_to(res.position)
			# Wybieramy powierzchnię, która jest najbliżej kursora
			if dist < min_distance:
				min_distance = dist
				closest_result = res
				
	return closest_result

func place_trap(click_position: Vector2):
	var result = get_surface_at_mouse(click_position)
	
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
			trap_instance.global_position = result.position
			
			trap_instance.rotation = result.normal.angle() + (PI / 2.0)
			add_child(trap_instance)
		else:
			trap_instance.queue_free()
			
	else:
		# Jeśli nas nie stać, usuwamy stworzoną przed chwilą instancję
		print("Za mało pieniędzy! Brakuje: ", trap_instance.cost - player_money)
		trap_instance.queue_free()


func _on_btn_spikes_pressed() -> void:
	pass # Replace with function body.
	
func destroy_trap_at_mouse():
	var trap_to_remove = get_trap_under_mouse()
	
	if trap_to_remove != null:
		player_money += int(trap_to_remove.cost)
		update_money_display()
		
		highlighted_trap = null
		trap_to_remove.queue_free()
		print("Usunięto pułapkę")
	
#------------------Traps--------------------

func select_spikes():
	_set_selected_trap(spikes_scene, "Kolce")
	
func select_trampoline():
	_set_selected_trap(trampoline_scene, "Trampolina")
	
func select_fan():
	_set_selected_trap(fan_scene, "Wiatrak")

func _set_selected_trap(new_scene: PackedScene, trap_label: String):
	is_destroy_mode = false
	if not can_place_traps: return
	
	selected_trap_scene = new_scene
	print("Wybrano: ", trap_label)
	
	var temp_instance = selected_trap_scene.instantiate()
	var sprite = temp_instance.get_node("Sprite2D") as Sprite2D
	
	if sprite:
		preview_sprite.texture = sprite.texture
		preview_sprite.offset = sprite.offset
		preview_sprite.scale = sprite.scale
		preview_sprite.centered = sprite.centered
	
	temp_instance.queue_free()

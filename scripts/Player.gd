extends RigidBody2D

@onready var camera = get_parent().get_node("Camera2D")
var blood = preload("res://scenes/blood.tscn")

var follow_mouse = true
var score = 0
var is_processing_damage = false

func _ready():
	gravity_scale = 0   # brak grawitacji na start
	GameState.level_run_phase_signal.connect(actvatePlayer)
	
func actvatePlayer():
	follow_mouse = false
	gravity_scale = 1  
	
func deactivatePlayer():
	gravity_scale = 0
	follow_mouse = true

func _physics_process(_delta):
	if follow_mouse:
		var mouse_pos = get_global_mouse_position()
		
		# 1. Pobieramy szerokość okna (surowe piksele)
		var screen_width = get_viewport_rect().size.x
		
		# 2. KLUCZOWE: Dzielimy przez zoom kamery, żeby poznać PRAWDZIWĄ szerokość w świecie gry
		var world_width = screen_width / camera.zoom.x
		
		# 3. Liczymy margines
		var margin = world_width / 6.0
		
		# 4. Pobieramy środek kamery
		var screen_center_x = camera.get_screen_center_position().x
		
		# 5. Wyznaczamy granice
		var min_x = screen_center_x - (world_width / 2.0) + margin
		var max_x = screen_center_x + (world_width / 2.0) - margin
		
		# 6. Ograniczamy pozycję X
		var target_x = clamp(mouse_pos.x, min_x, max_x)
		
		# 7. Ruch piłki
		linear_velocity.x = (target_x - global_position.x) * 5

func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO):
	if is_processing_damage:
		return
	
	is_processing_damage = true
	score += amount
	print("Piłka obrywa za: ", amount, " | Liczba punktów: ", score)
	
	# --- EFEKT KOLORU ---
	var tween = create_tween()
	$AnimatedSprite2D.modulate = Color.RED 
	tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)
	# --------------------
	
	spawn_blood_particles()
	# --- EFEKT KRWI (cząsteczki) ---
	#if source_position != Vector2.ZERO:
		#spawn_blood_particles_with_direction(source_position)
	#else:
		#spawn_blood_particles()
	# --------------------------------
	is_processing_damage = false

#func spawn_blood_particles():
	#if blood_particles_scene:
		#var blood = blood_particles_scene.instantiate()
		#blood.global_position = global_position
		#get_parent().add_child(blood)
		#
		## Uruchom cząsteczki
		#blood.emitting = true
		#
		## Automatycznie usuń po zakończeniu
		#await get_tree().create_timer(blood.lifetime).timeout
		#blood.queue_free()
#
#func spawn_blood_particles_with_direction(source_pos: Vector2):
	#if blood_particles_scene:
		#var blood = blood_particles_scene.instantiate()
		#blood.global_position = global_position
		#get_parent().add_child(blood)
		#
		#blood.emitting = true
		
		
const MAX_BLOOD_INSTANCES = 50

func spawn_blood_particles():
	# Sprawdź aktualną liczbę instancji krwi
	var blood_instances = get_tree().get_nodes_in_group("blood")
	
	if blood_instances.size() >= MAX_BLOOD_INSTANCES:
		print("Osiągnięto limit krwi: ", blood_instances.size())
		# Usuń najstarszą instancję
		if blood_instances.size() > 0 and is_instance_valid(blood_instances[0]):
			blood_instances[0].queue_free()
	
	var blood_instance = blood.instantiate()
	blood_instance.add_to_group("blood")
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	blood_instance.rotation = randf_range(0, 360)

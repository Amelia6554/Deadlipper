extends RigidBody2D

@onready var camera = get_parent().get_node("Camera2D")
var blood = preload("res://scenes/blood.tscn")

var follow_mouse = false
var score = 0
var is_processing_damage = false

func _ready():
	gravity_scale = 0   # brak grawitacji na start
	deactivatePlayer()
	GameState.level_run_phase_signal.connect(activatePlayer)
	#GameState.level_drop_player_phase_signal.connect(deactivatePlayer)
	
# run phase
func activatePlayer():
	follow_mouse = false
	gravity_scale = 1  
	
# drop phase
func deactivatePlayer():
	follow_mouse = false
	gravity_scale = 0
	
func follow_player():
	follow_mouse = true

func _physics_process(_delta):
	if follow_mouse:
		var mouse_pos = get_global_mouse_position()
		
		var screen_width = get_viewport_rect().size.x
		
		var world_width = screen_width / camera.zoom.x
		
		var margin = world_width / 6.0
		
		var screen_center_x = camera.get_screen_center_position().x
		
		var min_x = screen_center_x - (world_width / 2.0) + margin
		var max_x = screen_center_x + (world_width / 2.0) - margin
		
		var target_x = clamp(mouse_pos.x, min_x, max_x)
		
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
	is_processing_damage = false

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

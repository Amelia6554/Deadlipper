extends RigidBody2D

@onready var camera = get_parent().get_node("Camera2D")
var follow_mouse = true
var score = 0

func _ready():
	gravity_scale = 0   # brak grawitacji na start
	GameState.level_run_phase_signal.connect(actvatePlayer)
	
func actvatePlayer():
	follow_mouse = false
	gravity_scale = 1  

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

#func _unhandled_input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#follow_mouse = false
		#gravity_scale = 1   # włącz grawitację
		#camera.follow = true
		
func take_damage(amount: int):
	score += amount
	print("Piłka obrywa za: ", amount, " | Liczba punktów: ", score)
	
	# --- EFEKT KOLORU ---
	# Tworzymy tween (animator)
	var tween = create_tween()
	# 1. Błyskawicznie zmień kolor na czerwony
	$AnimatedSprite2D.modulate = Color.RED 
	# 2. W ciągu 0.2 sekundy wróć do białego (czyli naturalnego koloru)
	tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)
	# --------------------

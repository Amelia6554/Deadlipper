extends Camera2D

@export var scroll_speed: float = 200.0 # Prędkość przesuwania
@export var look_ahead_distance: float = 0.2 # Jak bardzo wyprzedzać (ułamek sekundy)
@export var max_look_ahead: float = 300.0    # Maksymalne wychylenie w pikselach
var margin_percent: float = 1.0 / 15.0 # Twój margines 1/15

var target: RigidBody2D = null
var follow: bool = false
var locked: bool = false

func _process(delta: float):
	# 1. Jeśli kamera jest zablokowana (po kliknięciu Start)
	if locked:
		if follow and target != null:
			# 1. Pobieramy prędkość piłki
			var velocity = target.linear_velocity
			
			# 2. Obliczamy przesunięcie (offset) na podstawie prędkości
			# Im szybciej spada (velocity.y), tym niżej patrzy kamera
			var target_offset = velocity * look_ahead_distance
			
			# 3. Ograniczamy maksymalne wychylenie, żeby kamera nie oszalała
			target_offset.x = clamp(target_offset.x, -max_look_ahead, max_look_ahead)
			target_offset.y = clamp(target_offset.y, -max_look_ahead, max_look_ahead)
			
			# 4. Płynnie przesuwamy kamerę do punktu: pozycja piłki + przesunięcie
			# Używamy lerp, żeby ruch był miękki dla oka
			var target_pos = target.global_position + target_offset
			global_position = global_position.lerp(target_pos, 10.0 * delta)
		else:
			# Jeśli jeszcze nie puszczono piłki - stój w miejscu (np. na 0,0)
			pass
	else:
		# 2. Jeśli nie kliknięto jeszcze Start - działaj Edge Scrolling
		handle_edge_scrolling(delta)

func handle_edge_scrolling(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	
	var move_vec = Vector2.ZERO
	
	# Marginesy w pikselach
	var margin_x = screen_size.x * margin_percent
	var margin_y = screen_size.y * margin_percent

	# OŚ X: Obliczamy siłę od 0.0 (na progu marginesu) do 1.0 (na samej krawędzi)
	if mouse_pos.x < margin_x:
		# Lewa krawędź: im mniejszy x, tym większa siła
		var strength = (margin_x - mouse_pos.x) / margin_x
		move_vec.x = -clamp(strength, 0, 1)
	elif mouse_pos.x > screen_size.x - margin_x:
		# Prawa krawędź: im większy x, tym większa siła
		var strength = (mouse_pos.x - (screen_size.x - margin_x)) / margin_x
		move_vec.x = clamp(strength, 0, 1)

	# OŚ Y: To samo dla góry i dołu
	if mouse_pos.y < margin_y:
		var strength = (margin_y - mouse_pos.y) / margin_y
		move_vec.y = -clamp(strength, 0, 1)
	elif mouse_pos.y > screen_size.y - margin_y:
		var strength = (mouse_pos.y - (screen_size.y - margin_y)) / margin_y
		move_vec.y = clamp(strength, 0, 1)

	# Zastosowanie ruchu
	global_position += move_vec * scroll_speed * zoom.x * delta
	
	
	
func follow_mouse():
	follow = false
	locked = false
	
func follow_player():
	follow = true
	locked = true
	
func static_camera():
	follow = false
	locked = true

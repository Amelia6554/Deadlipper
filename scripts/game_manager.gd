extends Node

@export var player_scene: PackedScene 
@export var spawn_point: Marker2D     
@export var btn_start: Button     

@export var trap_placer: Node2D      
@export var trap_ui_panel: Control 
@export var camera: Camera2D  

@export var level_ui: CanvasLayer

func _ready():
	# Podłączamy sygnał wciśnięcia przycisku do funkcji
	btn_start.pressed.connect(_on_start_pressed)
	

func _on_start_pressed():
	print("Gra wystartowała!")
	
	# 1. Ukrywamy przycisk 
	btn_start.hide() 
	
	if trap_ui_panel:
		trap_ui_panel.hide() 
		
	if trap_placer:
		trap_placer.can_place_traps = false
		trap_placer.selected_trap_scene = null
	
	# 2. Tworzymy instancję gracza
	var player = player_scene.instantiate()
	
	# 3. Ustawiamy go w pozycji naszego Marker2D (SpawnPoint)
	player.global_position = spawn_point.global_position
	
	# 4. Dodajemy gracza do sceny. 
	# get_parent() zadba o to, by gracz był na tym samym poziomie co Camera2D (żeby Twój skrypt gracza działał)
	get_parent().add_child(player)
	
	if camera:
		# Wyłączamy na chwilę możliwość Edge Scrollingu (jeśli chcesz)
		camera.target = player # Ustawiamy gracza jako cel
		camera.locked = true
		
		var camera_tween = create_tween()
		# Ustawiamy przejście kamery do punktu (0,0) w 0.5 sekundy
		camera_tween.tween_property(camera, "global_position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		if level_ui:
			level_ui.setup_player(player)

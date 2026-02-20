extends Node
#TODO shake screen option

@export var player_scene: PackedScene 
@export var spawn_point: Marker2D         

@export var trap_placer: Node2D      
@export var trap_ui_panel: Control 
@export var camera: Camera2D  

@export var level_ui: CanvasLayer

var player

func _ready():
	GameState.level_shop_phase_signal.connect(_on_shop_phase)
	GameState.level_drop_player_phase_signal.connect(_on_drop_phase)
	GameState.level_run_phase_signal.connect(_on_run_phase)
	GameState.level_completed_phase_signal.connect(_on_level_finished)

func restart_level():
	# Przeładowuje aktualnie otwartą scenę
	get_tree().reload_current_scene()
	GameState._shop_phase()
	
func _on_shop_phase():
	if trap_ui_panel:
		trap_ui_panel.show()
	if trap_placer:
		trap_placer.can_place_traps = true
	camera.follow_mouse()
	

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and GameState.get_current_state() == GameState.GameStateEnum.DROP:
		GameState._run_phase()

func _on_run_phase():
	camera.follow_player()
	trap_placer.activate_traps()

func _on_drop_phase():
	if trap_ui_panel:
		trap_ui_panel.hide() 
		
	if trap_placer:
		trap_placer.can_place_traps = false
		trap_placer.selected_trap_scene = null
	
	# 2. Tworzymy instancję gracza
	player = player_scene.instantiate()
	
	# 3. Ustawiamy go w pozycji naszego Marker2D (SpawnPoint)
	player.global_position = spawn_point.global_position
	
	# 4. Dodajemy gracza do sceny. 
	get_parent().add_child(player)
	
	if camera:
		camera.target = player
		camera.static_camera()

		# Wyłączamy sterowanie kulką na czas lotu kamery
		player.follow_mouse = false 

		var camera_tween = create_tween()
		camera_tween.tween_property(camera, "global_position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Kiedy kamera skończy lecieć, pozwól kulce śledzić myszkę
		camera_tween.finished.connect(func(): if is_instance_valid(player): player.follow_mouse = true)
		
		if level_ui:
			level_ui.setup_player(player)

func _on_level_finished():
	if is_instance_valid(player):
		player.queue_free()
		print("Kulka zniknęła!")
	
	GameState._shop_phase()

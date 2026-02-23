extends Node
#TODO shake screen option

@export var player_scene: PackedScene 
@export var spawn_point: Marker2D         

@export var trap_placer: Node2D      
@export var trap_ui_panel: Control 
@export var camera: Camera2D  

@export var level_ui: CanvasLayer

#States
var can_start_run: bool = false

var player

func _ready():
	GameState.level_shop_phase_signal.connect(_on_shop_phase)
	GameState.level_destruction_phase_signal.connect(_on_destruction_phase)
	GameState.level_drop_player_phase_signal.connect(_on_drop_phase)
	GameState.level_run_phase_signal.connect(_on_run_phase)
	GameState.level_completed_phase_signal.connect(_on_level_finished)
	GameState.level_restart_signal.connect(restart_level)

func restart_level():
	# Przeładowuje aktualnie otwartą scenę
	get_tree().reload_current_scene()
	GameState._shop_phase()
	
func _on_shop_phase():
	if trap_ui_panel:
		trap_ui_panel.show()
	if trap_placer:
		trap_placer.can_place_traps = true
	delete_player()
	camera.follow_mouse()
	trap_placer.deactivate_traps()
	clear_all_blood()

func _on_destruction_phase():
	trap_placer.select_destroy_tool()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameState.get_current_state() == GameState.GameStateEnum.DROP and can_start_run:
			if is_instance_valid(player):
				player.activatePlayer()
			GameState._run_phase()

func _on_run_phase():
	camera.follow_player()
	trap_placer.activate_traps()

func _on_drop_phase():
	can_start_run = false
	if trap_ui_panel:
		trap_ui_panel.hide() 
		
	if trap_placer:
		trap_placer.can_place_traps = false
		trap_placer.selected_trap_scene = null
		
	delete_player()
	
	player = player_scene.instantiate()
	
	player.global_position = spawn_point.global_position
	
	get_parent().add_child(player)
	
	
	if camera:
		camera.target = player
		camera.static_camera()
		

		var camera_tween = create_tween()
		camera_tween.tween_property(camera, "global_position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		camera_tween.finished.connect(func(): 
			if is_instance_valid(player):
				player.follow_player()
			can_start_run = true)
		
		if level_ui:
			level_ui.setup_player(player)

func _on_level_finished():
	if is_instance_valid(player):
		player.queue_free()
		print("Kulka zniknęła!")
	
	GameState._shop_phase()

func delete_player():
	if is_instance_valid(player):
		player.queue_free()
		player = null

func clear_all_blood():
	if not get_tree():
		print("Brak drzewa!")
		return
		
	var blood_effects = get_tree().get_nodes_in_group("blood")
	print("Znaleziono ", blood_effects.size(), " efektów krwi")
	
	for blood in blood_effects:
		if is_instance_valid(blood):
			blood.queue_free()

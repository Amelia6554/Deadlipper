extends Node
signal level_shop_phase_signal 
signal level_destruction_phase_signal
signal level_drop_player_phase_signal 
signal level_run_phase_signal 
signal level_completed_phase_signal 

signal pause_menu_toggled(is_paused)
signal level_restart_signal

enum GameStateEnum { SHOP, DESTRUCTION, DROP, RUN, COMPLETED, PAUSED }

var current_state = GameStateEnum.SHOP
var last_state = GameStateEnum.SHOP

func get_current_state():
	return current_state

func _shop_phase():
	print("Manager: Shop phase")
	current_state = GameStateEnum.SHOP
	level_shop_phase_signal.emit()

func _destruction_phase():
	print("Manager: Destruction phase")
	current_state = GameStateEnum.DESTRUCTION
	level_destruction_phase_signal.emit()

func _drop_phase():
	print("Manager: Drop phase")
	current_state = GameStateEnum.DROP
	level_drop_player_phase_signal.emit()

func _run_phase():
	print("Manager: Run phase")
	current_state = GameStateEnum.RUN
	level_run_phase_signal.emit()

func _completed_phase():
	print("Manager: Completed phase")
	current_state = GameStateEnum.COMPLETED
	level_completed_phase_signal.emit()
	
func _restart_level():
	print("Manager: restart level")
	current_state = GameStateEnum.SHOP
	level_restart_signal.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu():
	if current_state == GameStateEnum.PAUSED:
		Engine.time_scale = 1
		current_state = last_state  
		pause_menu_toggled.emit(false) 
	else:
		last_state = current_state
		Engine.time_scale = 0
		current_state = GameStateEnum.PAUSED
		pause_menu_toggled.emit(true) 
	
	print("Stan gry: ", current_state)

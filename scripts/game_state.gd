extends Node
signal level_shop_phase_signal 
signal level_drop_player_phase_signal 
signal level_run_phase_signal 
signal level_completed_phase_signal 

enum GameStateEnum { SHOP, DROP, RUN, COMPLETED }

var current_state = GameStateEnum.SHOP

func get_current_state():
	return current_state

func _shop_phase():
	print("Manager: Shop phase")
	current_state = GameStateEnum.SHOP
	level_shop_phase_signal.emit()

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

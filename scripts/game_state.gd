extends Node
signal level_completed_signal # Nazwijmy go tak, żeby się nie mylił

func _on_game_finished():
	print("Manager: Otrzymałem info o końcu poziomu!")
	level_completed_signal.emit() # Dzwonimy dzwonkiem

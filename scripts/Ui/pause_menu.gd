extends Control

@onready var pause_menu = self

func _ready():
	GameState.pause_menu_toggled.connect(_on_pause_toggled)
	
	pause_menu.hide()

func _on_pause_toggled(is_paused):
	$MarginContainer/VBoxContainer/BtnResume.grab_focus()
	if is_paused:
		pause_menu.show()
	else:
		pause_menu.hide()


func _on_resume_pressed() -> void:
	GameState.pauseMenu()


func _on_restart_pressed() -> void:
	GameState.pauseMenu()
	GameState._restart_level()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

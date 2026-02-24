extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/BtnPlay.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level_0.tscn")


func _on_btn_option_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()

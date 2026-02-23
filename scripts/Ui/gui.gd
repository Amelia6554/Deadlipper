extends CanvasLayer

var player: Node2D = null 

@export var progress_bar : ProgressBar
@export var score_label: Label
@export var btn_start: Button
@export var end_level_area: Area2D

var end_of_level_y: float = 5000.0
var start_y: float = 0.0

func _ready():
	btn_start.pressed.connect(_on_start_pressed)
	GameState.level_shop_phase_signal.connect(_on_shop_phase)
	

	
func _on_shop_phase():
	btn_start.show()
	


func setup_player(new_player: Node2D) -> void:
	player = new_player
	
	start_y = player.global_position.y
	
	end_of_level_y = end_level_area.global_position.y
	progress_bar.min_value = 0
	progress_bar.max_value = end_of_level_y - start_y
	
	
	progress_bar.value = progress_bar.max_value
	print("UI podłączone do gracza!")

func _process(_delta: float) -> void:
	if player != null:
		var distance_left = end_of_level_y - player.global_position.y
		
		progress_bar.value = distance_left
		
		if score_label != null:
			score_label.text = "Damage: " + str(player.score)

#---Buttons---------------------------------------

func _on_start_pressed():
	print("Start button pressed")
	btn_start.hide()
	GameState._drop_phase()

func _on_restart_player_pressed() -> void:
	GameState._shop_phase()
	
func _on_destruction_pressed():
	GameState._destruction_phase()

extends Node

@export var player_scene: PackedScene 
@export var spawn_point: Marker2D     
@export var btn_start: Button        

func _ready():
	# Podłączamy sygnał wciśnięcia przycisku do funkcji
	btn_start.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	print("Gra wystartowała!")
	
	# 1. Ukrywamy przycisk 
	btn_start.hide() 
	
	# 2. Tworzymy instancję gracza
	var player = player_scene.instantiate()
	
	# 3. Ustawiamy go w pozycji naszego Marker2D (SpawnPoint)
	player.global_position = spawn_point.global_position
	
	# 4. Dodajemy gracza do sceny. 
	# get_parent() zadba o to, by gracz był na tym samym poziomie co Camera2D (żeby Twój skrypt gracza działał)
	get_parent().add_child(player)

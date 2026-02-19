extends CanvasLayer

@export var player: Node2D
@export var progress_bar : ProgressBar
@export var hp_label: Label

var end_of_level_y: float = 5000.0
var start_y: float = 0.0

func _ready() -> void:
	if player != null:
		# Zapisujemy, na jakiej wysokości gracz zaczyna grę
		start_y = player.global_position.y
		
		# Pasek liczy teraz od 0 (pusty dół) do całkowitego dystansu (pełna góra)
		progress_bar.min_value = 0
		progress_bar.max_value = end_of_level_y - start_y
		
		# Na samym starcie ustalamy pasek na maksimum (jest pełny)
		progress_bar.value = progress_bar.max_value
	else:
		print("BŁĄD: Nie przypisano gracza do paska postępu!")

func _process(_delta: float) -> void:
	if player != null:
		# Obliczamy, ile pikseli zostało nam jeszcze do mety
		var distance_left = end_of_level_y - player.global_position.y
		
		# Pasek pokazuje ten "pozostały dystans" (więc maleje w miarę spadania)
		progress_bar.value = distance_left
		
	#if hp_label != null:
			## Zmieniamy tekst w Labelu, dodając string "HP: " i aktualną wartość hp gracza
			#hp_label.text = "HP: " + str(player.hp)

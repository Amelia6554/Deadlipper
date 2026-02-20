extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Meta: Gracz wykryty!")
		GameState._on_game_finished() # Wołamy funkcję z Managera

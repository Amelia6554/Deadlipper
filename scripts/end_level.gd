extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Meta: Gracz wykryty!")
		GameState._completed_phase() # Wołamy funkcję z Managera

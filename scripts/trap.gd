extends Area2D
class_name Trap # To sprawi, że Godot rozpozna "Trap" jako nowy typ węzła!

# Wspólne zmienne dla KAŻDEJ pułapki
@export var trap_name: String = "Nieznana Pułapka"
@export var cost: int = 50
@export var damage: int = 10
@export var is_active: bool = true

# Funkcja wywoływana, gdy piłka dotknie pułapki
func trigger_trap(body: Node2D):
	if is_active:
		print("Pułapka ", trap_name, " aktywowana!")
		apply_effect(body)

# Pusta funkcja. Będziemy ją "nadpisywać" w konkretnych pułapkach!
func apply_effect(_body: Node2D):
	pass

extends Area2D

@export var speed: float = 400.0 # Prędkość pocisku
@export var damage: float = 20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	target = find_target()

var target: Node2D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target != null and is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		
		global_rotation = direction.angle()
		
		global_position += direction * speed * delta
	else:
		var forward = Vector2.RIGHT.rotated(global_rotation)
		global_position += forward * speed * delta

func find_target():
	if get_tree().has_group("Player"):
		target = get_tree().get_nodes_in_group("Player")[0]
		print("Znalazłem cel: ", target.name) 
	else:
		print("BŁĄD: Nie znalazłem gracza w grupie 'Player'!")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position) 
		queue_free()
	

extends Trap

@export var BULLET: PackedScene = null

var target: Node2D = null
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var rayCast = $RayCast2D
@onready var turret_sprite = $TurretSprite

func _init():
	trap_name = "Działko"
	cost = 200
	damage = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.level_run_phase_signal.connect(find_target)


func _physics_process(delta: float) -> void:
	if target != null:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target

		if rayCast.is_colliding() and rayCast.get_collider().is_in_group("Player"):
			turret_sprite.rotation = angle_to_target
			
			if reloadTimer.is_stopped():
				turret_sprite.play("shoot") 
				reloadTimer.start()
				#shoot(angle_to_target)

func shoot(shoot_angle: float):
	print("bullet")
	
	if BULLET and target:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = global_position
		bullet.global_rotation = shoot_angle 
		bullet.target = target
		
	
func find_target():
	if get_tree().has_group("Player"):
		target = get_tree().get_nodes_in_group("Player")[0]
		print("Znalazłem cel: ", target.name) 
	else:
		print("BŁĄD: Nie znalazłem gracza w grupie 'Player'!")

func _on_turret_sprite_frame_changed() -> void:
	if turret_sprite.animation == "shoot" and turret_sprite.frame == 6:
		var angle_to_target = turret_sprite.rotation
		shoot(angle_to_target) 

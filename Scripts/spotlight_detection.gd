extends Node3D
@export var is_spotlight : bool
@onready var spotlight = $Area3D/SpotLight3D
@onready var ray_follow_player = $"Look At Player/Ray Follow Player"
@onready var look_at_player = $"Look At Player"
@onready var player_detected = false
@onready var target
@onready var enemy_has_target = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not target == null:
		look_at_player.look_at(target.colshape.global_transform.origin)
		if ray_follow_player.is_colliding():
			var ray_follow_collider = ray_follow_player.get_collider()
			if ray_follow_collider.is_in_group("Player") and not target == null:
				player_detected = true
			elif ray_follow_collider.is_in_group("Enemy") and not target == null:
				player_detected = true
			else:
				player_detected = false
	else:
		player_detected = false
	
	if player_detected:
		#if is_spotlight:
			#spotlight.light_energy = lerp(spotlight.light_energy, 2.0, 0.05)
		#$TestMesh.visible = false
		$TestMesh.global_transform.origin = lerp($TestMesh.global_transform.origin, ray_follow_player.get_collision_point(), 0.25)
		$Area3D.look_at($TestMesh.global_transform.origin)
	else:
		#if is_spotlight:
			#spotlight.light_energy = lerp(spotlight.light_energy, 1.0, 0.05)
		$Area3D.look_at($"Return Origin".global_transform.origin)
		
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		if not enemy_has_target:
			target = null

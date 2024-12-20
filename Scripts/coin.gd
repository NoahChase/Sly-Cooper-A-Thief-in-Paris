extends Node3D

@onready var ray = $RayCast3D
@onready var velocity = Vector3.ZERO
@onready var can_pickup = false
@onready var hp = 1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var num_x
var num_z
var num_y



# Called when the node enters the scene tree for the first time.
func _ready():
	num_x = randf_range(-3, 3)
	num_z = randf_range(-3, 3)
	num_y = -0.75
	$"Drop Timer".start(0.25)

func _process(delta):
	if not $AudioStreamPlayer.playing == true and $GPUParticles3D.emitting == false and $MeshInstance3D.visible == false:
			queue_free()
	if $"Drop Timer".time_left == 0 and can_pickup and not $AudioStreamPlayer.playing == true:
		if hp == 1:
			Global.coins += 1
			$AudioStreamPlayer.pitch_scale = randf_range(1.35, 1.85)
			$AudioStreamPlayer.play()
			print("cha ching! ", Global.coins)
			$GPUParticles3D.emitting = true
			$MeshInstance3D.visible = false
			hp = 0
		
		

func _physics_process(delta):
	if not ray.is_colliding():
		num_y = lerpf(num_y, 1, 0.05)
		position.z += delta * lerpf(num_z, 0, .1)
		position.x += delta * lerpf(num_x, 0, .1)
		position.y -= (gravity * num_y) * delta
		

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		can_pickup = true
		

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		can_pickup = false

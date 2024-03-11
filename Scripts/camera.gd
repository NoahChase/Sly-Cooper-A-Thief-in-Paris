extends Node3D

@onready var camera = $CameraArm/camera
@onready var is_grounded
@onready var cam_home = $CameraArm/cam_home
@onready var cam_safe = $CameraArm/cam_safe

func _ready():
	pass

func _process(delta):
	if is_grounded:
		camera.position = lerp(camera.position, cam_safe.position, 0.125)
	else:
		camera.position = lerp(camera.position, cam_home.position, 0.125)

func _on_area_3d_body_entered(body):
	is_grounded = true
		
func _on_area_3d_body_exited(body):
	is_grounded = false

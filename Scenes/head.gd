extends Node3D
@onready var camera_ray = $camera_ray
@onready var cam_node = $cam_node
@onready var camera = $CameraOrigin/CameraArm/camera



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if camera_ray.is_colliding():
		#camera.global_transform.origin = lerp(camera.global_transform.origin, camera_ray.get_collision_point(), 0)
	#else:
		#camera.global_transform.origin = cam_node.global_transform.origin

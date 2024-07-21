extends Node3D

@onready var camera = $CameraTarget/Camera3D
@onready var camera_return = $CameraTarget/Camera_Return

@export var camera_target = Node3D
@export var camera_player = CharacterBody3D
@export var pitch_max = 50
@export var pitch_min = -50

var right_stick_pressure
var left_stick_pressure
@onready var handling_obstruction = false
var distance = Vector3()
@onready var avg_distance = 1

var yaw = float()
var pitch = float()
var yaw_sens = 0.001
var pitch_sens = 0.001

var default_camera_offset := Vector3(0, 0, -4.5)

@onready var ray_front = $CameraTarget/RayCast_Front
@onready var raycasts = [
	$CameraTarget/Camera3D/RayCast_Left,
	$CameraTarget/Camera3D/RayCast_Left1,
	$CameraTarget/Camera3D/RayCast_Left2,
	$CameraTarget/Camera3D/RayCast_Right,
	$CameraTarget/Camera3D/RayCast_Right1,
	$CameraTarget/Camera3D/RayCast_Right2,
	$CameraTarget/Camera3D/RayCast_Back,
	$CameraTarget/Camera3D/RayCast_Bottom,
	$CameraTarget/Camera3D/RayCast_Top
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() !=0:
		yaw += -event.relative.x * yaw_sens * avg_distance
		pitch += event.relative.y * pitch_sens * avg_distance

func _physics_process(delta):
	left_stick_pressure = Input.get_action_strength("left_stick_left") + Input.get_action_strength("left_stick_right") + Input.get_action_strength("left_stick_up") + Input.get_action_strength("left_stick_down")
	right_stick_pressure = Input.get_action_strength("right_stick_left") + Input.get_action_strength("right_stick_right") + Input.get_action_strength("right_stick_up") + Input.get_action_strength("right_stick_down")
	camera_target.rotation.y = lerpf(camera_target.rotation.y, yaw, delta * 25)
	camera_target.rotation.x = lerpf(camera_target.rotation.x, pitch, delta * 25)
	
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	
	var cam_input_x = Input.get_axis("right_stick_right", "right_stick_left")
	var cam_input_y = Input.get_axis("right_stick_up", "right_stick_down")
	var camerainput = Vector2(cam_input_x, cam_input_y)
	
	yaw += camerainput.x * (yaw_sens) * 30 * avg_distance
	pitch += camerainput.y * (pitch_sens) * 20  * avg_distance
	$CameraTarget/Camera3D/CanvasLayer/RichTextLabel2.text = str("H", Global.health, "    P", Global.power_ups, "    $", Global.coins)
	
	if $CameraTarget/RayCast_Out.is_colliding():
		var ray_out_collider = $CameraTarget/RayCast_Out.get_collider()
		var ray_out_distance = ray_out_collider.position - camera_target.global_position
		if not ray_out_collider.is_in_group("Player"):
			camera.global_transform.origin = lerp(camera.global_transform.origin, $CameraTarget/Camera_Return_Back.global_transform.origin, 0.025)
			#pitch = lerp(pitch, 0.6, .012)
	elif ray_front.is_colliding():
		var ray_front_collider = ray_front.get_collider()
		if not ray_front_collider.is_in_group("Player"):
			camera.global_transform.origin = lerp(camera.global_transform.origin, ray_front.get_collision_point(), 0.15)
	else:
		return_camera_to_position(delta)
	
	handle_camera_obstruction(delta)
	
 
func return_camera_to_position(delta):
	camera.global_position = camera.global_position.lerp(camera_return.global_transform.origin, 0.015)
	if right_stick_pressure == 0.0 and left_stick_pressure > 0.5 and handling_obstruction == false and camera_player.state_now == camera_player.State.FLOOR:
		var cam_reset_speed
		if pitch >= 0.4:
			cam_reset_speed = 0.005
		elif pitch <= 0.4:
			cam_reset_speed = 0.01
		pitch = lerp(pitch, 0.35, cam_reset_speed)

func handle_camera_obstruction(delta):
	var colliding_ray = get_colliding_ray()
	if colliding_ray == "right":
		yaw = lerp(yaw, yaw - 3 * delta * (1 - avg_distance), 0.125)
	if colliding_ray == "left":
		yaw = lerp(yaw, yaw + 3 * delta * (1 - avg_distance), 0.125)
	if colliding_ray == "top":
		if pitch > -0.18:
			pitch = lerp(pitch, pitch - 4 * delta, 0.125)
	if colliding_ray == "bottom":
		pitch = lerp(pitch, pitch + 4 * delta * distance.y, 0.125)
		

func get_colliding_ray():
	for raycast in raycasts:
		if raycast.is_colliding():
			var ray_collider = raycast.get_collider()
			if not ray_collider.is_in_group("Player"):
				distance = raycast.get_collision_point() - camera.global_transform.origin
				if distance.x < 0:
					distance.x = distance.x * -1
				if distance.y < 0:
					distance.y = distance.y * -1
				if distance.z < 0:
					distance.z = distance.z * -1
				avg_distance = (distance.x + distance.y + distance.z) / 3
				handling_obstruction = true
				var raycast_name = raycast.get_name()
				if raycast_name == "RayCast_Right":
					return "right"
				if raycast_name == "RayCast_Right1":
					return "right"
				if raycast_name == "RayCast_Right2":
					return "right"
				if raycast_name == "RayCast_Left":
					return "left"
				if raycast_name == "RayCast_Left1":
					return "left"
				if raycast_name == "RayCast_Left2":
					return "left"
				if raycast_name == "RayCast_Top":
					return "top"
				if raycast_name == "RayCast_Bottom":
					return "bottom"
		else:
			handling_obstruction = false
			distance = Vector3(1.0,1.0,1.0)
			avg_distance = 1

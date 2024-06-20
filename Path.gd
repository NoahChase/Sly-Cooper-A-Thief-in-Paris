extends Node3D

@export var basis_type = 1
@export var manual_y_rotation : float = 0.0

@onready var test_ball = $"Path3D/PathFollow3D/Test Ball"
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path = $Path3D
@export var target : CharacterBody3D
@onready var move_ball = true
@export var length = 0.0
@export var start_clamp = 0.01
@export var end_clamp = 0.99
var tween : Tween

var speed = 0.001
var previous_position : Vector3

func _ready():
	test_ball.mesh.visible = false
	previous_position = path_follow_3d.global_transform.origin
func _physics_process(delta):
	if test_ball.is_selected:
		if target != null:
			move_ball = false
			if target.anim_player.current_animation != "spin":
				var camera_direction = test_ball.global_transform.origin - target.camera_parent.camera.global_transform.origin
				
				if target.state_now == target.State.ON_PLATFORM:
					target.global_transform.origin = test_ball.global_transform.origin
					target.sly_container.rotation.y = lerp(target.sly_container.rotation.y, -test_ball.rotation.y, 0.1)
				speed = 1
				
				
				if basis_type == 1:
					if test_ball.move_forward:
						if camera_direction.x > 0:
							path_follow_3d.progress_ratio += delta / (length / speed) + 0.002
						else:
							path_follow_3d.progress_ratio -= delta / (length / speed) + 0.002
					if test_ball.move_backward:
						if camera_direction.x > 0:
							path_follow_3d.progress_ratio -= delta / (length / speed) + 0.002
						else:
							path_follow_3d.progress_ratio += delta / (length / speed) + 0.002
				if basis_type == 2:
					if test_ball.move_forward:
						path_follow_3d.progress_ratio -= delta / (length / speed) + 0.002
					if test_ball.move_backward:
						path_follow_3d.progress_ratio += delta / (length / speed) + 0.002
				if basis_type == 3:
					if test_ball.move_forward:
						if camera_direction.z > 0:
							path_follow_3d.progress_ratio += delta / (length / speed) + 0.002
						else:
							path_follow_3d.progress_ratio -= delta / (length / speed) + 0.002
					if test_ball.move_backward:
						if camera_direction.z > 0:
							path_follow_3d.progress_ratio -= delta / (length / speed) + 0.002
						else:
							path_follow_3d.progress_ratio += delta / (length / speed) + 0.002
	elif target != null:
		move_ball = true
	if move_ball:
		var player_relative_position = test_ball.global_transform.origin - target.get_node("Movement Offset").global_transform.origin
		speed = length * 2
		if basis_type == 1:
			if player_relative_position.x < 0:
				path_follow_3d.progress_ratio += delta / (length / speed)
			elif player_relative_position.x > 0:
				path_follow_3d.progress_ratio -= delta / (length / speed)
		if basis_type == 2:
			if player_relative_position.y > 0:
				path_follow_3d.progress_ratio += delta / (length / speed)
			elif player_relative_position.y < 0:
				path_follow_3d.progress_ratio -= delta / (length / speed)
		if basis_type == 3:
			if player_relative_position.z < 0:
				path_follow_3d.progress_ratio += delta / (length / speed)
			elif player_relative_position.z > 0:
				path_follow_3d.progress_ratio -= delta / (length / speed)
				
	path_follow_3d.progress_ratio = clamp(path_follow_3d.progress_ratio, start_clamp, end_clamp)
	
	update_ball_rotation()

func update_ball_rotation():
	var current_position = path_follow_3d.global_transform.origin
	var direction = (current_position - previous_position).normalized()
	
	if basis_type == 2:
		# rotate sly to match the curve of the pole (not implimented)
		pass
	elif direction.length() > 0.1:
		var rotation_angle = -atan2(direction.x, direction.z)
		test_ball.rotation.y = rotation_angle
	
	previous_position = current_position

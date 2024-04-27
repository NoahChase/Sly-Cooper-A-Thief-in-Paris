extends Node3D

@export var basis_type = 1

@onready var test_ball = $"Path3D/PathFollow3D/Test Ball"
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path = $Path3D
@onready var target
@onready var move_ball = false
@export var length = 0.0
@onready var animation_player = $AnimationPlayer

var speed = 0.001

func _ready():
	test_ball.mesh.visible = false
func _process(delta):
	#make ball only move forward when player is on it so they don't teleport.
	if test_ball.is_selected:
		if not target == null:
			move_ball = false
			if not target.anim_player.current_animation == "spin":
				var to_target = target.global_transform.origin - test_ball.global_transform.origin
				var distance = to_target.length()
				var camera_direction = test_ball.global_transform.origin - target.get_node("CameraOrigin/CameraArm/camera").global_transform.origin
				target.global_transform.origin = lerp(target.global_transform.origin, test_ball.global_transform.origin, 0.5)
				target.rotation.x = test_ball.rotation.x
				target.rotation.z = test_ball.rotation.z
				speed = 1
				
				if basis_type == 1:
					if test_ball.move_forward:
						if camera_direction.x > 0:
							path_follow_3d.progress_ratio += delta / (length/speed) + 0.002
						else:
							path_follow_3d.progress_ratio -= delta / (length/speed)+ 0.002
					if test_ball.move_backward:
						if camera_direction.x > 0:
							path_follow_3d.progress_ratio -= delta / (length/speed)+ 0.002
						else:
							path_follow_3d.progress_ratio += delta / (length/speed)+ 0.002
				if basis_type == 2:
					if test_ball.move_forward:
						path_follow_3d.progress_ratio -= delta / (length/speed)+ 0.002
					if test_ball.move_backward:
						path_follow_3d.progress_ratio += delta / (length/speed)+ 0.002
				if basis_type == 3:
					if test_ball.move_forward:
						if camera_direction.z > 0:
							path_follow_3d.progress_ratio += delta / (length/speed)+ 0.002
						else:
							path_follow_3d.progress_ratio -= delta / (length/speed)+ 0.002
					if test_ball.move_backward:
						if camera_direction.z > 0:
							path_follow_3d.progress_ratio -= delta / (length/speed)+ 0.002
						else:
							path_follow_3d.progress_ratio += delta / (length/speed)+ 0.002
	elif not target == null:
		move_ball = true
	if move_ball == true:
		var player_relative_position = test_ball.global_transform.origin - target.global_transform.origin
		speed = length * 2
		if basis_type == 1:
			if player_relative_position.x < 0:
				path_follow_3d.progress_ratio += delta / (length/speed)
			elif player_relative_position.x > 0:
				path_follow_3d.progress_ratio -= delta / (length/speed)
		if basis_type == 2:
			if player_relative_position.y > 0:
				path_follow_3d.progress_ratio += delta / (length/speed)
			elif player_relative_position.y < 0:
				path_follow_3d.progress_ratio -= delta / (length/speed)
		if basis_type == 3:
			if player_relative_position.z < 0:
				path_follow_3d.progress_ratio += delta / (length/speed)
			elif player_relative_position.z > 0:
				path_follow_3d.progress_ratio -= delta / (length/speed)
	
	path_follow_3d.progress_ratio = clamp(path_follow_3d.progress_ratio, 0.01, 0.99)
	
	
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		move_ball = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		move_ball = false


func _on_sparklearea_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("twinkle")

func _on_sparklearea_body_exited(body):
	if body.is_in_group("Player"):
		animation_player.stop()

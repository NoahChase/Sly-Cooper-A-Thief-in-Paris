extends Node3D

@export var basis_type = 1

@onready var test_ball = $"Path3D/PathFollow3D/Test Ball"
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var path = $Path3D
@export var target = CharacterBody3D
@onready var move_ball = true
@export var length = 0.0
@export var start_clamp = 0.01
@export var end_clamp = 0.99
var tween = Tween

var speed = 0.001

func _ready():
	test_ball.mesh.visible = false
	
	
func _physics_process(delta):
	#make ball only move forward when player is on it so they don't teleport.
	if test_ball.is_selected:
		if not target == null:
			move_ball = false
			if not target.anim_player.current_animation == "spin":
				var camera_direction = test_ball.global_transform.origin - target.camera_parent.camera.global_transform.origin
								
				### SET THESE when Player is TWEENING (not on platform yet) -this should be same as player's tween function-
				#var x_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				#var y_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				#var z_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				#var to_target = target.global_transform.origin - global_transform.origin
				#var distance = to_target.length()
				#x_tween.tween_property(
				#target,
				#"position:x",
				#test_ball.global_transform.origin.x,
				#distance / (target.SPEED * target.SPEED_MULT),
				#).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
				#y_tween.tween_property(
				#target,
				#"position:y",
				#test_ball.global_transform.origin.y,
				#distance / (target.SPEED * target.SPEED_MULT),
				#).set_trans(Tween.TRANS_QUART)
	
				#z_tween.tween_property(
				#target,
				#"position:z",
				#test_ball.global_transform.origin.z,
				#distance / (target.SPEED * target.SPEED_MULT),
				#).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
				
				### Set this when player is on platform (done tweening)
				target.global_transform.origin = lerp(target.global_transform.origin, test_ball.global_transform.origin, 0.5)
				
				#target.rotation.x = test_ball.rotation.x
				#target.rotation.z = test_ball.rotation.z
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
				
	
	path_follow_3d.progress_ratio = clamp(path_follow_3d.progress_ratio, start_clamp, end_clamp)

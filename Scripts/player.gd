extends CharacterBody3D

const SPEED = 3.25
var JUMP_VELOCITY = 7.9
const max_jumps = 1
const lerp_val = 0.15

@onready var direction

@onready var target_a
@onready var target_b
@onready var target_type
@onready var target

@onready var feet = $Feet
@onready var head = $head

@export var platform: Node3D = null

@onready var ray_v = $Ray_V_Container/Ray_V
@onready var ray_h = $Ray_H
@onready var ray_h2 = $Ray_H2
@onready var ray_h3 = $Ray_H3
@onready var ray_h4 = $Ray_H4
@onready var sly_ray_h1 = $sly_container/sly_cooper/Ray_H
@onready var sly_ray_h2 = $sly_container/sly_cooper/Ray_H2
@onready var sly_ray_h3 = $sly_container/sly_cooper/Ray_H3
@onready var sly_ray_h4 = $sly_container/sly_cooper/Ray_H4
@onready var ray_v_holder = $Ray_V_Container
@onready var ray_v_ball = $Ray_V_Container/Ray_V_Ball
@onready var to_ray_ball = ray_v_ball.global_transform.origin - global_transform.origin
@onready var distance_to_ball = to_ray_ball.length()

@onready var sly_container = $sly_container
@onready var sly_rot = $sly_container/sly_rot_helper
@onready var sly = $sly_container/sly_cooper

@onready var camera_origin = $CameraOrigin
@onready var camera = $CameraOrigin/CameraArm/camera
@onready var camera_arm = $CameraOrigin/CameraArm
@onready var canvas_animation = $CameraOrigin/CameraArm/camera/CanvasLayer/CanvasAnimation


@onready var area_anim = $"Platform Snap Area/Area Col Anim Player"
@onready var anim_player = $AnimationPlayer
@onready var sly_anim_tree = $sly_container/sly_cooper.get_node("AnimationTree")
@onready var sly_container_anim = $sly_container/sly_container_anim
@onready var current_blendspace
@export var sens = 0.125

var SPEED_MULT = 1
var jump_counter = 0

var can_climb = false
var can_ledge = true

var is_moving = false
var is_on_point = false


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum Platform_Type{NULL, POINT, PATH, POLE, ROPE, LEDGE, Ray_V_Ball}
@export var platform_type := Platform_Type.NULL

@onready var floor_anim: String
@export var air_anim: String



@onready var bottle_number = 30

 
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event):
	#if Input.is_action_just_pressed("ESC"):
		#pass
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camera_origin.rotate_x(deg_to_rad(-event.relative.y * sens))
		camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-75), deg_to_rad(35))
		if not is_moving or not is_on_floor:
			sly_container.rotate_y(deg_to_rad(event.relative.x * sens))
	#if aim_direction != Vector2.ZERO:
		#rotate_y(value.x * sens)
		#camera_origin.rotate_x(value.y * sens)
		#camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(40))
		#if not is_moving or not is_on_floor:
			#sly_container.rotate_y(deg_to_rad(value.y * sens))


func _physics_process(delta):
	$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel3.text = str(Engine.get_frames_per_second())
	print("physics process start! physics target = ", target)
	var aim_direction := Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")
	var value := Vector2.ZERO
	var raw_value := Vector2.ZERO
	value.x = Input.get_action_strength("right_stick_left") - Input.get_action_strength("right_stick_right")
	value.y = Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")
	if value.x >= 0.0001 or value.x <= 0.0001:
		if Input.is_action_pressed("right_stick_left") or Input.is_action_pressed("right_stick_right"):
			rotate_y(deg_to_rad(value.x*2))
			if not is_moving or not is_on_floor:
				sly_container.rotate_y(deg_to_rad(-value.x*2))
	if value.y >= 0.0001 or value.y <= 0.0001:
		if Input.is_action_pressed("right_stick_up") or Input.is_action_pressed("right_stick_down"):
			camera_origin.rotate_x(deg_to_rad(value.y *1.25))
			camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-75), deg_to_rad(35))
			
	
	if platform_type == Platform_Type.POINT:
		print("physics process! platform type = POINT")
	if platform_type == Platform_Type.PATH:
		print("physics process! platform type = PATH")
	if platform_type == Platform_Type.POLE:
		print("physics process! platform type = POLE")
	if platform_type == Platform_Type.ROPE:
		print("physics process! platform type = ROPE")
	if platform_type == Platform_Type.LEDGE:
		print("physics process! platform type = LEDGE")
	if platform_type == Platform_Type.Ray_V_Ball:
		pass
	if platform_type == Platform_Type.NULL:
		print("physics process! platform type = NULL")
		air_anim = "not_on_floor"
		floor_anim = "on_floor"
		if not target == null and not target.is_in_group("Ray_V_Ball"):
			if target.is_in_group("Path"):
				target.move_forward = false
				target.move_backward = false
				sly_anim_tree.set("parameters/Pole_BlendSpace/blend_position", 0)
				sly_anim_tree.set("parameters/Rope_BlendSpace/blend_position", 0)
			target.is_selected = false
			target = null
		target = null
		target_a = null
	if not is_on_floor():
		sly_anim_tree.set("parameters/Transition/transition_request", air_anim)
		SPEED_MULT = 1.4
		velocity.y -= gravity * delta * 1.5
		if area_anim.current_animation == "area_check":
			target_distance_manager()
		if Input.is_action_just_pressed("RMB"):
			target_distance_manager()
			if not area_anim.is_playing():
				area_anim.play("area_expand")
				area_anim.queue("area_check")
	else: 
		#SPEED_MULT = 1
		jump_counter = 0
		sly_anim_tree.set("parameters/Transition/transition_request", floor_anim)

	#make BlendSpace1D a variable of all blend spaces, just like air_anim and floor_anim (so works in all states)
	sly_anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length()/SPEED)
	sly_anim_tree.set("parameters/Hang_BlendSpace/blend_position", velocity.length()/SPEED)
	sly_anim_tree.set("parameters/Ledge_BlendSpace/blend_position", velocity.length()/SPEED)

	sly_anim_tree.set("parameters/Blend3/blend_amount", -1)

	if Input.is_action_just_pressed("ui_accept"):
		platform_type = Platform_Type.NULL
		jump_counter += 1
		#print(jump_counter)
		if jump_counter <= 1: 
			if target != null:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y += JUMP_VELOCITY + 0.75
			sly_anim_tree.set("parameters/OneShot/request", 1)
		elif jump_counter == 2:
			#sly_container_anim.play("w_flip")
			velocity.y += JUMP_VELOCITY * 0.567
			if velocity.y > 7.9:
				velocity.y = 7.9
	
	if Input.is_action_pressed("SHIFT"):
		if is_on_floor() or target!= null:
			SPEED_MULT = 1.8
	else:
		if is_on_floor() or target!= null:
			SPEED_MULT = 1

	var input_dir = Input.get_vector("A", "D", "W", "S")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not platform_type == Platform_Type.POLE or platform_type == Platform_Type.ROPE:
			is_moving = true
			sly_rot.look_at(position - direction)
			sly_container.rotate_y(lerp(sly.rotation.y, sly_rot.rotation.y, lerp_val))
		var left_stick_pressure = Input.get_action_strength("left_stick_left") + Input.get_action_strength("left_stick_right") + Input.get_action_strength("left_stick_up") + Input.get_action_strength("left_stick_down")
		if left_stick_pressure >= 0.85:
			left_stick_pressure = 1.0
		if left_stick_pressure <= 0.35 and left_stick_pressure > 0:
			left_stick_pressure = 0.35
		velocity.x = lerp(velocity.x, direction.x * SPEED * SPEED_MULT * left_stick_pressure, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * SPEED * SPEED_MULT * left_stick_pressure, lerp_val)
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel4.text = str(left_stick_pressure)
	else:
		is_moving = false
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)

	if platform_type == Platform_Type.POLE or platform_type == Platform_Type.ROPE or platform_type == Platform_Type.LEDGE:
		if not target == null:
			#platform.global_transform.origin
			if Input.is_action_pressed("W"):
				target.move_forward = true
				sly_anim_tree.set("parameters/Pole_BlendSpace/blend_position", velocity.length()/SPEED)
				sly_anim_tree.set("parameters/Rope_BlendSpace/blend_position", velocity.length()/SPEED)
			if Input.is_action_just_released("W"):
				target.move_forward = false
				sly_anim_tree.set("parameters/Pole_BlendSpace/blend_position", 0)
				sly_anim_tree.set("parameters/Rope_BlendSpace/blend_position", 0)
			if Input.is_action_pressed("S"):
				target.move_backward = true
				sly_anim_tree.set("parameters/Pole_BlendSpace/blend_position", -velocity.length()/SPEED)
				sly_anim_tree.set("parameters/Rope_BlendSpace/blend_position", velocity.length()/SPEED)
			if Input.is_action_just_released("S"):
				target.move_backward = false
				sly_anim_tree.set("parameters/Pole_BlendSpace/blend_position", 0)
				sly_anim_tree.set("parameters/Rope_BlendSpace/blend_position", 0)
			jump_counter = 0
	else:
		if bottle_number >= 30:
			ledge_detect()
		move_and_slide()
	
	if Input.is_action_pressed("TAB"):
		canvas_animation.play("out_in_out")
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel.text = str(bottle_number, "/30")



func manage_target_type():
	#SPEED_MULT = 0
	print("managing target type")
	if target == null:
		platform_type = Platform_Type.NULL
	if target.is_in_group("Point"):
		platform_type = Platform_Type.POINT
		air_anim = "not_on_floor"
		floor_anim = "on_floor"
	if target.is_in_group("Path"):
		target.target = self
		target.is_selected = true
	if target.is_in_group("Pole"):
		platform_type = Platform_Type.POLE
		air_anim = "on_pole"
		floor_anim = "on_pole"
	if target.is_in_group("Rope"):
		platform_type = Platform_Type.ROPE
		air_anim = "on_rope"
		floor_anim = "on_rope"
	if target.is_in_group("Ledge"):
		platform_type = Platform_Type.LEDGE
		air_anim = "not_on_floor"
		floor_anim = "on_ledge"
	if target.is_in_group("Ray_V_Ball"):
		platform_type = Platform_Type.Ray_V_Ball
		air_anim = "not_on_floor"
		floor_anim = "on_floor"
	print("platform type = ", platform_type)

func find_target_b():
	print("finding target b!")

	if distance_to_ball < 3.5:
		if target_b == null:
			if $Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation == "check_ledge_final" and can_ledge:
				if not is_on_floor():
					$Ray_V_Container/Particle_Sparkle.visible = true
					$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation = "check_ledge_final"
					target_b = ray_v_ball
	else:
		target_b = null
	print(distance_to_ball)
	print("target_b = ", target_b)

func target_distance_manager():
	find_target_b()
	print("managing target distance!")
	if target_a == null and target_b != null:
		target = target_b
	elif target_a != null and target_b == null:
		target = target_a
	elif target_a != null and target_b != null:
		var to_target_a = target_a.global_transform.origin - global_transform.origin
		var to_target_b = target_b.global_transform.origin - global_transform.origin
		var distance_a = to_target_a.length()
		var distance_b = to_target_b.length()
		#one with least distance (Target A vs B)
		#one with least distance (Hand vs Feet)
		if distance_a <= distance_b:
			target = target_a
		else:
			target = target_b
	print("target = ", target)
	if not target == null:
		manage_target_type()
		move_to_target()

func move_to_target():
	print("moving to target!")
	if target != null:
		if target == target_a:
			platform = target.get_node("platform")
		elif target == target_b:
			platform = target
		var to_target = platform.global_transform.origin - global_transform.origin
		var distance = to_target.length()

		var tween = create_tween()
		if not anim_player.current_animation == "spin":
			anim_player.play("spin")
			tween.tween_property(
				self,
				"position",
				platform.global_transform.origin,
				distance/(SPEED*SPEED_MULT),
			).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
			sly_anim_tree.set("parameters/Transition/transition_request", "not_on_floor")
			$AnimationPlayer.queue("RESET")

func ledge_detect():
	var hit_ray_h1 = ray_h.get_collision_point()
	var hit_ray_h2 = ray_h2.get_collision_point()
	var hit_ray_h3 = ray_h3.get_collision_point()
	var hit_ray_h4 = ray_h4.get_collision_point()
	var hit_sly_ray_h1 = sly_ray_h1.get_collision_point()
	var hit_sly_ray_h2 = sly_ray_h2.get_collision_point()
	var hit_sly_ray_h3 = sly_ray_h3.get_collision_point()
	var hit_sly_ray_h4 = sly_ray_h4.get_collision_point()
	var hit_ray_h_final = Vector3()
	
	var hit_ray_v = ray_v.get_collision_point()
	var offset = Vector3(0,60,0)
	var offset_num = 0.0
	var final_offset = Vector3(0,offset_num,0)
	
	if ray_h.is_colliding():
		hit_ray_h_final = hit_ray_h1
	elif ray_h2.is_colliding():
		hit_ray_h_final = hit_ray_h2
	elif ray_h3.is_colliding():
		hit_ray_h_final = hit_ray_h3
	elif ray_h4.is_colliding():
		hit_ray_h_final = hit_ray_h4
	elif sly_ray_h1.is_colliding():
		hit_ray_h_final = hit_sly_ray_h1
	elif sly_ray_h2.is_colliding():
		hit_ray_h_final = hit_sly_ray_h2
	elif sly_ray_h3.is_colliding():
		hit_ray_h_final = hit_sly_ray_h3
	elif sly_ray_h4.is_colliding():
		hit_ray_h_final = hit_sly_ray_h4
		
	ray_v_holder.global_transform.origin = hit_ray_h_final + offset
	ray_v_ball.global_transform.origin = hit_ray_v
	$Ray_V_Container/Particle_Sparkle.global_transform.origin = hit_ray_v
	
	to_ray_ball = ray_v_ball.global_transform.origin - global_transform.origin
	distance_to_ball = to_ray_ball.length()
		
	if not $Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation == "check_ledge_final" and distance_to_ball <= 3:
		$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.play("check_ledge")
		$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.queue("check_ledge_final")

func _on_platform_snap_area_body_entered(body):
	if body.is_in_group("Platform"):
		if target == null:
			target_a = body
			print("target_a = ", target_a)
			can_climb = true
			target_distance_manager()
			print("can_climb = ", can_climb)
		else:
			print("have target = ", target)



func _on_platform_snap_area_body_exited(body):
	if body.is_in_group("Platform"):
		print("Body exited: ", body)
		can_climb = false
		#if not body.is_in_group("Path"):
			#target = null



func _on_ball_area_body_exited(body):
	if not body.is_in_group("Player"):
		can_ledge = true
		#print("cl",can_ledge)



func _on_ball_area_body_entered(body):
	if not body.is_in_group("Player"):
		can_ledge = false
		$Ray_V_Container/Particle_Sparkle.visible = false
	else:
		$Ray_V_Container/Particle_Sparkle.visible = false
		#print("cl",can_ledge)

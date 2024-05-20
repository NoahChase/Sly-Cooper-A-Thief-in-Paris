extends CharacterBody3D

const SPEED = 4.8
var JUMP_VELOCITY = 7.5
const lerp_val = 0.15
var air_accel = 0.0

#in-game jump distance = 6
#in-game jump height = 2
#in-game double jump height = 3

@onready var direction

@onready var target_a
@onready var target_b
@onready var target_type
@onready var target

@onready var feet = $Feet
@onready var head = $Head
@onready var offset_num

@export var platform: Node3D = null

@onready var ray_v = $Ray_V_Container/Ray_V
@onready var ray_h = $sly_container/Ray_H8
@onready var ray_h2 = $sly_container/Ray_H5
@onready var ray_h3 = $sly_container/Ray_H6
@onready var ray_h4 = $sly_container/Ray_H7
@onready var sly_ray_h1 = $sly_container/Ray_H
@onready var sly_ray_h2 = $sly_container/Ray_H2
@onready var sly_ray_h3 = $sly_container/Ray_H3
@onready var sly_ray_h4 = $sly_container/Ray_H4
@onready var ray_v_holder = $Ray_V_Container
@onready var ray_v_ball = $Ray_V_Container/Ray_V_Ball
@onready var to_ray_ball = ray_v_ball.global_transform.origin - global_transform.origin
@onready var distance_to_ball = to_ray_ball.length()

@onready var sly_container = $sly_container
@onready var sly_rot = $sly_container/sly_rot_helper
@onready var sly = $sly_container/sly_cooper

@onready var sly_new = $sly_container/SlyCooper_RigNoPhysics

@onready var camera_origin = $CameraOrigin
@onready var camera = $CameraOrigin/CameraArm/camera
@onready var camera_arm = $CameraOrigin/CameraArm
@onready var canvas_animation = $CameraOrigin/CameraArm/camera/CanvasLayer/CanvasAnimation

@onready var area_anim = $"Platform Snap Area/Area Col Anim Player"
@onready var anim_player = $AnimationPlayer
@onready var sly_anim_tree = $sly_container/SlyCooper_RigNoPhysics.get_node("AnimationTree")
@onready var sly_container_anim = $sly_container/sly_container_anim
@onready var current_blendspace
@onready var coyote_timer = $"Coyote Time"
@onready var airtime = 0

@export var sens = 0.15

var SPEED_MULT = 1
var DIRECTION_MULT
@onready var double_jump: bool = true

@onready var left_stick_pressure
@onready var can_right_stick

var can_climb = false
var can_ledge = true

var is_moving = false
var is_on_point = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum State{FLOOR, AIR, TWEENING, ON_PLATFORM}
@export var state_now := State.FLOOR
enum Platform_Type{NULL, POINT, PATH, POLE, ROPE, LEDGE, Ray_V_Ball}
@export var platform_type := Platform_Type.NULL

@onready var floor_anim: String
@export var air_anim: String
@export var platform_anim: String

@onready var bottle_number = 30
@onready var blend_pos = velocity.length()/SPEED
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_right_stick = true
	double_jump = true

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camera_origin.rotate_x(deg_to_rad(-event.relative.y * sens))
		camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		if not is_moving or not is_on_floor or state_now == State.AIR:
			sly_container.rotate_y(deg_to_rad(event.relative.x * sens))



func joystick_event():
	var aim_direction := Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")
	var value := Vector2.ZERO
	var raw_value := Vector2.ZERO
	#make BlendSpace1D a variable of all blend spaces, just like air_anim and floor_anim (so works in all states)
	sly_anim_tree.set("parameters/floor_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/rope_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/pole_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/ledge_blend/blend_position", blend_pos)

	#sly_anim_tree.set("parameters/Blend3/blend_amount", -1)
	
	if can_right_stick:
		value.x = Input.get_action_strength("right_stick_left") - Input.get_action_strength("right_stick_right")
		value.y = Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")
		if value.x >= 0.0001 or value.x <= 0.0001:
			if Input.is_action_pressed("right_stick_left") or Input.is_action_pressed("right_stick_right"):
				rotate_y(deg_to_rad(value.x*2.25))
				if not is_moving or not is_on_floor or state_now == State.AIR:
					
					sly_container.rotate_y(deg_to_rad(-value.x*2))
		if value.y >= 0.0001 or value.y <= 0.0001:
			if Input.is_action_pressed("right_stick_up") or Input.is_action_pressed("right_stick_down"):
				camera_origin.rotate_x(deg_to_rad(value.y *1.5))
				camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-80), deg_to_rad(20))
	left_stick_pressure = Input.get_action_strength("left_stick_left") + Input.get_action_strength("left_stick_right") + Input.get_action_strength("left_stick_up") + Input.get_action_strength("left_stick_down")
	if left_stick_pressure >= 0.45:
		if state_now == State.FLOOR:
			if not SPEED_MULT == 1.8:
				sly_anim_tree.set("parameters/TimeScale/scale", 1.2)
			else:
				sly_anim_tree.set("parameters/TimeScale/scale", 1)
			left_stick_pressure = 1.0
	if left_stick_pressure <= 0.35 and left_stick_pressure > 0:
		if state_now == State.FLOOR:
			sly_anim_tree.set("parameters/TimeScale/scale", 1.7)
		left_stick_pressure = 0.35



func _physics_process(delta):
	blend_pos = velocity.length()/SPEED
	$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel3.text = str(Engine.get_frames_per_second())
	print("physics process start! physics target = ", target)
	joystick_event()

### State Handler

	if target == null:
		if not is_on_floor():
			state_now = State.AIR
		else:
			state_now = State.FLOOR
	else:
		if state_now != State.TWEENING:
			state_now = State.ON_PLATFORM
	
### Delta Input Handler

	if Input.is_action_just_pressed("ui_accept"):
		if state_now == State.TWEENING:
			state_now == State.AIR
			jump()
		else:
			jump()
	if Input.is_action_pressed("SHIFT"):
		if is_on_floor() or target!= null:
			SPEED_MULT = 1.8
	else:
		if is_on_floor() or target!= null:
			SPEED_MULT = 1
	if Input.is_action_pressed("TAB"):
		canvas_animation.play("out_in_out")
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel.text = str(bottle_number, "/30")

### State Machine

	if state_now == State.FLOOR:
		if SPEED_MULT == 1.8:
			air_accel = lerpf(air_accel, 0.8, lerp_val)
		else:
			air_accel = 1
		$"CameraOrigin/Jump Counter".text = str("[center]","double jump is ", double_jump)
		can_right_stick = true
		var input_dir = Input.get_vector("A", "D", "W", "S")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		$"CameraOrigin/State Reader".text = str("[center]FLOOR")
		#SPEED_MULT = 1
		double_jump = true
		sly_anim_tree.set("parameters/Move_State/transition_request", floor_anim)
		
	
	if state_now == State.AIR:
		airtime = clamp(airtime, 0, 1)
		var camoffset = Vector3(0,-2,0)
		can_right_stick = true
		$"CameraOrigin/State Reader".text = str("[center]AIR")
		sly_anim_tree.set("parameters/Move_State/transition_request", air_anim)
		SPEED_MULT = 1.2
		
		if coyote_timer.time_left >= 0.25:
			#could start a 1 second timer and say air_accel = timer value...
			air_accel = 1
			airtime = -1
		else:
			air_accel = lerpf(air_accel, 0.0, lerp_val/2.25)
			airtime += delta
		
		sly_anim_tree.set("parameters/Air_Blend/blend_amount", airtime)
		velocity.y -= gravity * delta * 1.75

		if area_anim.current_animation == "area_check":
			target_distance_manager()
		if Input.is_action_just_pressed("RMB"):
			target_distance_manager()
			if not area_anim.is_playing():
				area_anim.play("area_expand")
				area_anim.queue("area_check")
	
	if state_now == State.TWEENING:

		air_accel = lerpf(air_accel, 1, lerp_val)
		can_right_stick = true
		sly_anim_tree.set("parameters/Move_State/transition_request", air_anim)
		sly_anim_tree.set("parameters/Move_State/transition_request", floor_anim)
		double_jump = true
		$"CameraOrigin/State Reader".text = str("[center]TWEENING")
		if platform_type == Platform_Type.POINT:
			sly_anim_tree.set("parameters/BlendSpace1D/blend_position", 0)
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
			print("physics process! platform type = LEDGE")
			#platform_type = Platform_Type.NULL
			#return
		if platform_type == Platform_Type.POLE or platform_type == Platform_Type.ROPE or platform_type == Platform_Type.LEDGE or platform_type == Platform_Type.Ray_V_Ball:
			if not target == null and not platform_type == Platform_Type.Ray_V_Ball:
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
			elif platform_type == Platform_Type.Ray_V_Ball and offset_num != 0.6:
				if offset_num != 0.6:
					sly_anim_tree.set("parameters/Hang_BlendSpace/blend_position", 0)
				else:
					#make this foot grab an automatic walk, no holding in place. this needs a separate Platform_Type (Ray_V_Feet and Ray_V_Hands)
					pass
	elif state_now == State.ON_PLATFORM:
		#send a signal when the tween is finished and set the state to on_platform
		pass
	else:
		#ledge_detect()
		target_distance_manager()
		move_and_slide()
	if platform_type == Platform_Type.NULL:
			print("physics process! platform type = NULL")
			air_anim = "air"
			floor_anim = "floor"
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
	
	if not is_on_floor() and not state_now == State.TWEENING and not state_now == State.ON_PLATFORM:
		if velocity.y > 0:
			camera_origin.position.y = lerp(camera_origin.position.y, (max(2, -velocity.y * delta) - $Camera_Return.position.y), velocity.y * delta/4)
			
		elif velocity.y < 0:
			camera_origin.position.y = lerp(camera_origin.position.y, $Camera_Return.position.y - max(velocity.y, -velocity.y * delta) + 1, -velocity.y * delta /4)
		if velocity.y > 0:
			sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y - 1.25, lerp_val/4)
		elif velocity.y <= 0:
			sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y, lerp_val/4)
	elif state_now == State.TWEENING or state_now == State.ON_PLATFORM or is_on_floor():
		camera_origin.position.y = lerp(camera_origin.position.y, $Camera_Return.position.y - max(2, -velocity.y * delta), delta * 1.5)
		sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y, lerp_val * 1.5)
		if left_stick_pressure > 0.9:
			camera_origin.position.y = lerp(camera_origin.position.y, $Camera_Return.position.y + 0.05, delta/4)
			
### Direction Handling
	var input_dir = Input.get_vector("A", "D", "W", "S")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not platform_type == Platform_Type.POLE or platform_type == Platform_Type.ROPE:
			is_moving = true
			sly_rot.look_at(position - direction)
			sly_container.rotate_y(lerp(sly.rotation.y, sly_rot.rotation.y, lerp_val * air_accel * 45 * delta))
		
		velocity.x = lerp(velocity.x, direction.x * SPEED * SPEED_MULT * left_stick_pressure, lerp_val * 45 * air_accel * delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED * SPEED_MULT * left_stick_pressure, lerp_val * 45 * air_accel * delta)
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel4.text = str(left_stick_pressure)
	else:
		is_moving = false
		velocity.x = lerp(velocity.x, 0.0, lerp_val * 45 * air_accel * delta)
		velocity.z = lerp(velocity.z, 0.0, lerp_val * 45 * air_accel * delta)


func jump():
	platform_type = Platform_Type.NULL
	$jump_sound.pitch_scale = randf_range(0.7, 1)
	if double_jump:
		coyote_timer.start(0.3)
		$jump_sound.volume_db = -35
		$jump_sound.play()
		if state_now == State.FLOOR or state_now == State.TWEENING:
			velocity.y = JUMP_VELOCITY + 0.75
			sly_anim_tree.set("parameters/Jump_State/transition_request", "Floor_Jump")
			sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
			
		if state_now == State.AIR:
			sly_anim_tree.set("parameters/Jump_State/transition_request", "W_Jump")
			sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
			if velocity.y >= 3:
				velocity.y += 3.4
			elif velocity.y > 0 and velocity.y < 3:
				velocity.y += JUMP_VELOCITY * 0.65
			elif velocity.y <= 0:
				velocity.y += JUMP_VELOCITY - 1
				
		double_jump = false
		
#	if double_jump == true:
#		jump
#	if elif coyote timer > 0 and double_jump == true:
#		air jump
#	if not is on floor and coyote timer.is_stopped():
#		air jump
#		double_jump = false


func manage_target_type():
	#SPEED_MULT = 0
	print("managing target type")
	if target == null:
		platform_type = Platform_Type.NULL
		return
	if target.is_in_group("Point"):
		platform_type = Platform_Type.POINT
		air_anim = "point"
		floor_anim = "point"
	if target.is_in_group("Path"):
		target.target = self
		target.is_selected = true
	if target.is_in_group("Pole"):
		platform_type = Platform_Type.POLE
		air_anim = "pole"
		floor_anim = "pole"
	if target.is_in_group("Rope"):
		platform_type = Platform_Type.ROPE
		air_anim = "rope"
		floor_anim = "rope"
	if target.is_in_group("Ledge"):
		platform_type = Platform_Type.LEDGE
		air_anim = "air"
		floor_anim = "ledge"
	if target.is_in_group("Ray_V_Ball"):
		platform_type = Platform_Type.Ray_V_Ball
		if offset_num == -0.7:
			air_anim = "ray_v_ball"
			floor_anim = "ray_v_ball"
		else:
			air_anim = "air"
			floor_anim = "air"
	print("platform type = ", platform_type)

func find_target_b():
	print("finding target b!")
	
	if distance_to_ball < 2 and can_ledge and velocity.y < 1 and state_now == State.AIR:
		if target_b == null:
			if $Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation == "check_ledge_final" and can_ledge:
				if not is_on_floor():
					$Ray_V_Container/Particle_Sparkle.visible = true
					$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation = "check_ledge_final"
					target_b = ray_v_ball
	else:
		$Ray_V_Container/Particle_Sparkle.visible = false
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
		elif distance_a> distance_b and not target_a == null:
			target = target_b
	print("target = ", target)
	if not target == null:
		move_to_target()

func move_to_target():
	print("moving to target!")
	if target != null:
		var to_feet = feet.global_transform.origin - target.global_transform.origin
		var to_head = head.global_transform.origin - target.global_transform.origin
		
		if target == target_a:
			platform = target.get_node("platform")
			offset_num = 0.0
		else:
			platform = target
			if to_feet.length() <= to_head.length():
				offset_num = 0.6
			else:
				offset_num = -0.7
		manage_target_type()
		var final_offset = Vector3(0,offset_num,0)
		var to_target = platform.global_transform.origin - global_transform.origin
		var distance = to_target.length()
		
		var x_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		var y_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		var z_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

		if not sly_container_anim.current_animation == "spin":
			var target_position = platform.global_transform.origin + final_offset
			
			x_tween.tween_property(
				self,
				"position:x",
				platform.global_transform.origin.x,
				distance / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
			y_tween.tween_property(
				self,
				"position:y",
				platform.global_transform.origin.y,
				distance / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_QUART)
	
			z_tween.tween_property(
				self,
				"position:z",
				platform.global_transform.origin.z,
				distance / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			sly_anim_tree.set("parameters/Move_State/transition_request", "air")
			$AnimationPlayer.queue("RESET")
			
			
			if platform_type == Platform_Type.POINT:
				sly_container_anim.play("spin")
			if target == target_a:
				sly_anim_tree.set("parameters/Jump_State/transition_request", "Spin")
				sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
			
			if x_tween.is_running() and y_tween.is_running() and z_tween.is_running():
				state_now = State.TWEENING
			elif target != null:
				state_now = State.ON_PLATFORM
		
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
		
	if not $Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.current_animation == "check_ledge_final" and distance_to_ball <= 2:
		$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.play("check_ledge")
		$Ray_V_Container/Ray_V_Ball/Ledge_Col_Anim.queue("check_ledge_final")
	### should show when you can do a ledge grab, just like the ledge grab Particle_Sparkle
	#if can_ledge and distance_to_ball < 3.5:
		#ray_v_ball.visible = true
	#else:
		#ray_v_ball.visible = false



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



func _on_platform_snap_area_area_entered(area):
	if area.is_in_group("Platform"):
		if target == null:
			target_a = area
			print("target_a = ", target_a)
			can_climb = true
			target_distance_manager()
			print("can_climb = ", can_climb)
		else:
			print("have target = ", target)
func _on_platform_snap_area_area_exited(area):
	if not area.is_in_group("Player"):
		can_ledge = true



func _on_ball_area_body_exited(body):
	if not body.is_in_group("Player"):
		can_ledge = true
		#print("cl",can_ledge)
func _on_ball_area_body_entered(body):
	can_ledge = false
		#print("cl",can_ledge)


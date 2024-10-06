extends CharacterBody3D

#### Redo Processing for Movement (add bool can_move parameter to direction)
#### Redo Animation OneShot Processing (one space where these are all updated and prioritized)
#### Check if animation is playing, change can_move to false or true


const SPEED = 4
var JUMP_VELOCITY = 8
const lerp_val = 0.15
var air_accel = 0.0

#in-game jump distance = 6
#in-game jump height = 2
#in-game double jump height = 3
@onready var can_rotate = true
@onready var direction
@onready var input_dir
@onready var grav_mult = 1

@onready var target_a
@onready var target_b
@onready var target_type
@onready var target
@onready var distance_to_target = 0
@onready var to_target
@onready var is_pickpocketing = false
@onready var do_big_jump = false
@onready var big_jump_mult = 2

@onready var feet = $Feet
@onready var head = $Head
@onready var colshape = $CollisionShape3D
@onready var offset_num

@export var platform: Node3D = null

@onready var sly_return = $sly_container/Sly_Return
@onready var ray_v = $Ray_V_Container/Ray_V
@onready var ray_h = $sly_container/Ray_Top
@onready var ray_h1 = $sly_container/Ray_H
@onready var ray_h2 = $sly_container/Ray_H2
@onready var ray_h3 = $sly_container/Ray_H3
@onready var ray_top = $sly_container/Ray_Top
@onready var ray_v_holder = $Ray_V_Container
@onready var ray_v_ball = $Ray_V_Container/Ray_V_Ball
@onready var ray_wall_top = $"sly_container/Wall Top"
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
@export var camera_target: Node3D
@export var camera_parent: Node3D
var camera_T = float()
var cam_speed = float()


@onready var area_anim = $"Platform Snap Area/Area Col Anim Player"
@onready var anim_player = $AnimationPlayer
@onready var sly_anim_player = $sly_container/SlyCooper_RigNoPhysics.get_node("AnimationPlayer")
@onready var sly_anim_tree = $sly_container/SlyCooper_RigNoPhysics.get_node("AnimationTree")
@onready var sly_container_anim = $sly_container/sly_container_anim
@onready var current_blendspace
@onready var coyote_timer = $"Coyote Time"
@onready var camtime = $Camtime
@onready var airtime = 0
@onready var cam_y_follow = true
@export var sens = 0.15

var SPEED_MULT = 1
var DIRECTION_MULT
@onready var double_jump: bool = true

@onready var left_stick_pressure
@onready var true_left_stick_pressure
@onready var can_right_stick

var can_climb = false
var can_ledge = true
var can_wall = false
var can_wall_timer = true

var is_moving = false
var is_on_point = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum State{FLOOR, WALL, AIR, TWEENING, ON_PLATFORM}
@export var state_now := State.FLOOR
enum Platform_Type{NULL, POINT, PATH, POLE, ROPE, LEDGE, Ray_V_Ball, WALL}
@export var platform_type := Platform_Type.NULL

@onready var floor_anim: String
@export var air_anim: String
@export var platform_anim: String

@onready var bottle_number = 30
@onready var coins = 0
@onready var blend_pos = velocity.length()/SPEED


@onready var player_hit = false

func _ready():
	camera_target = camera_parent.camera_target
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_right_stick = false
	double_jump = true

func _input(event):
	pass

func joystick_event():
	var aim_direction := Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")
	var value := Vector2.ZERO
	var raw_value := Vector2.ZERO
	#make BlendSpace1D a variable of all blend spaces, just like air_anim and floor_anim (so works in all states)
	sly_anim_tree.set("parameters/floor_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/rope_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/pole_blend/blend_position", blend_pos)
	sly_anim_tree.set("parameters/ledge_blend/blend_position", blend_pos)

	left_stick_pressure = Input.get_action_strength("left_stick_left") + Input.get_action_strength("left_stick_right") + Input.get_action_strength("left_stick_up") + Input.get_action_strength("left_stick_down")
	true_left_stick_pressure = Input.get_action_strength("left_stick_left") + Input.get_action_strength("left_stick_right") + Input.get_action_strength("left_stick_up") + Input.get_action_strength("left_stick_down")
	if left_stick_pressure > 1:
		left_stick_pressure = 1
	if state_now == State.FLOOR:
		if not SPEED_MULT == 1.7:
			if left_stick_pressure >= 0.5:
				sly_anim_tree.set("parameters/TimeScale/scale", 1.1)
				left_stick_pressure = 1.0
			if left_stick_pressure <= 0.5 and left_stick_pressure > 0:
				sly_anim_tree.set("parameters/TimeScale/scale", 1.5)
				left_stick_pressure = 0.5
		else:
			left_stick_pressure = 1
			sly_anim_tree.set("parameters/TimeScale/scale", 1)


func _process(delta):
	if state_now == State.FLOOR and Input.is_action_just_pressed("RMB"):
		pickpocket()
	if $"Pickpocket Time".time_left <= 0.01:
		is_pickpocketing = false
	
	if state_now == State.FLOOR and Input.is_action_just_pressed("LMB"):
		hit()

func _physics_process(delta):
	camera_smooth_follow(delta)
	blend_pos = velocity.length()/SPEED
	$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel3.text = str(Engine.get_frames_per_second())
	#print("physics process start! physics target = ", target)
	joystick_event()
	
### State Handler
	#wall_detect()
	if not target == null:
		distance_to_target = feet.global_transform.origin.y - platform.global_transform.origin.y
		
	
	if target == null:
		if not can_wall and not is_on_floor():
			state_now = State.AIR
		else:
			state_now = State.FLOOR
			
### Delta Input Handler
	
	if Input.is_action_just_pressed("ui_accept"):
#		if state_now == State.ON_PLATFORM:
#			state_now == State.AIR
#			jump()
#		else:
		jump()
	if Input.is_action_just_pressed("LALT") or Input.is_action_just_pressed("L2"):
		if state_now == State.ON_PLATFORM:
			state_now == State.AIR
			high_jump()
		else:
			high_jump()
	
	if Input.is_action_pressed("SHIFT"):
		if is_on_floor() or target!= null:
			SPEED_MULT = 1.7
	else:
		if is_on_floor() or target!= null:
			SPEED_MULT = 1
	if Input.is_action_pressed("TAB"):
		canvas_animation.play("out_in_out")
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel.text = str(bottle_number, "/30")
	
	#$"CameraOrigin/Jump Counter".text = str("[center]","double jump is ", double_jump, distance_to_target)
	$"CameraOrigin/Jump Counter".text = str(distance_to_target)
### State Machine
	if state_now == State.FLOOR:
		#can_wall = true
		#can_wall_timer = true
		$sly_container/paraglider.visible = false
		if SPEED_MULT == 1.7:
			air_accel = lerpf(air_accel, 0.8, lerp_val)
		else:
			air_accel = 1
		can_right_stick = false
		$"CameraOrigin/State Reader".text = str("[center]FLOOR")
		double_jump = true
		sly_anim_tree.set("parameters/Move_State/transition_request", floor_anim)
		if player_hit:
			if coyote_timer.is_stopped():
				coyote_timer.start(0.3)
			if coyote_timer.time_left <= 0.1:
				player_hit = false
		
	if state_now == State.WALL:
		self.visible = false
		#timer starts (if timer stops line of code goes with gravity line)
		#jump counter reset
	
	if state_now == State.AIR:
		ledge_detect()
		var grav_mult
		airtime = clamp(airtime, 0, 1)
		var camoffset = Vector3(0,-2,0)
		can_right_stick = false
		$"CameraOrigin/State Reader".text = str("[center]AIR")
		sly_anim_tree.set("parameters/Move_State/transition_request", air_anim)
		SPEED_MULT = 1.1
		if coyote_timer.time_left >= 0.3:
			#could start a 1 second timer and say air_accel = timer value...
			air_accel = 0.8
			airtime = -1
		else:
			if not Input.is_action_pressed("SHIFT"):
				air_accel = lerpf(air_accel, 0.0, lerp_val / 2)
			else:
				air_accel = lerpf(air_accel, 0.05, lerp_val)
			airtime += delta
			
		
		# When using the paraglider
		if Input.is_action_pressed("SHIFT"):
			if velocity.y >= -2.25:
				velocity.y -= gravity * delta * 2
			if velocity.y < -2.25:
				$sly_container/paraglider.visible = true
				velocity.y += 0.25
				SPEED_MULT = 1.2
		else:
			velocity.y -= gravity * delta * 2
			$sly_container/paraglider.visible = false


		sly_anim_tree.set("parameters/Air_Blend/blend_amount", airtime)
		
		if Input.is_action_just_pressed("RMB"):
			target_distance_manager()
			if not area_anim.is_playing():
				area_anim.play("area_expand")
				area_anim.queue("area_check")
	
	if state_now == State.TWEENING:
		$"CameraOrigin/State Reader".text = str("[center]TWEENING")
		if distance_to_target == 0:
			state_now = State.ON_PLATFORM
		air_accel = lerpf(air_accel, 1, lerp_val)
		can_right_stick = false
		sly_anim_tree.set("parameters/Move_State/transition_request", air_anim)
		sly_anim_tree.set("parameters/Move_State/transition_request", floor_anim)
		double_jump = true
		
			#platform_type = Platform_Type.NULL
			#return
		
	elif state_now == State.ON_PLATFORM:
		air_accel = lerpf(air_accel, 1, lerp_val)
		can_right_stick = false
		sly_anim_tree.set("parameters/Move_State/transition_request", air_anim)
		sly_anim_tree.set("parameters/Move_State/transition_request", floor_anim)
		double_jump = true
		$"CameraOrigin/State Reader".text = str("[center]ON_PLATFORM", distance_to_target)
		#send a signal when the tween is finished and set the state to on_platform
		if platform_type == Platform_Type.POINT:
			sly_anim_tree.set("parameters/BlendSpace1D/blend_position", 0)
			print("physics process! platform type = POINT")
		if platform_type == Platform_Type.PATH:
			print("physics process! platform type = PATH")
		if platform_type == Platform_Type.POLE:
			print("physics process! platform type = POLE")
			$sly_container/SlyCooper_RigNoPhysics.get_node("Ball Tail Root/Ball Anim").play("pole")
		if platform_type == Platform_Type.ROPE:
			print("physics process! platform type = ROPE")
		if platform_type == Platform_Type.LEDGE:
			print("physics process! platform type = LEDGE")
		if platform_type == Platform_Type.Ray_V_Ball:
			print("physics process! platform type = Ray_V_Ball")
		if platform_type == Platform_Type.POLE or platform_type == Platform_Type.ROPE or platform_type == Platform_Type.LEDGE or platform_type == Platform_Type.Ray_V_Ball:
			if not target == null and not platform_type == Platform_Type.Ray_V_Ball:
				#platform.global_transform.origin
				if Input.is_action_pressed("W") or Input.is_action_pressed("A") or Input.is_action_pressed("D"):
					target.move_forward = true
					
				if Input.is_action_just_released("W") or Input.is_action_just_released("A") or Input.is_action_just_released("D"):
					if not Input.is_action_pressed("W") or Input.is_action_pressed("A") or Input.is_action_pressed("D"):
						target.move_forward = false
						
				
				if Input.is_action_pressed("S"):
					target.move_backward = true
					
				if Input.is_action_just_released("S"):
					target.move_backward = false
					
			elif platform_type == Platform_Type.Ray_V_Ball:
				if offset_num != 0.6:
					sly_anim_tree.set("parameters/Hang_BlendSpace/blend_position", left_stick_pressure)
				else:
					#make this foot grab an automatic walk, no holding in place. this needs a separate Platform_Type (Ray_V_Feet and Ray_V_Hands)
					pass
	else:
		move_and_slide()
	if platform_type == Platform_Type.NULL:
			#print("physics process! platform type = NULL")
			if player_hit:
				air_anim = "flail"
			else:
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
			
	
### Adjust Sly on Jump
#	if not is_on_floor() and not state_now == State.TWEENING and not state_now == State.ON_PLATFORM:
#		if velocity.y > 0:
#			sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y - 1, lerp_val/6)
#		elif velocity.y <= 0:
#			sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y, lerp_val/6)
#	elif state_now == State.TWEENING or state_now == State.ON_PLATFORM or is_on_floor():
#		sly_new.position.y = lerp(sly_new.position.y, $sly_container/Sly_Return.position.y, lerp_val * 1.5)
	
### Direction Handling
	camera_T = camera_target.global_transform.basis.get_euler().y
	var horizontal = Input.get_axis("D", "A")
	var vertical = Input.get_axis("S", "W")
	input_dir = Vector3(horizontal, 0, vertical).normalized()
	direction = (transform.basis * Vector3(horizontal, 0, vertical).rotated(Vector3.UP, camera_T)).normalized()
	if direction and not is_pickpocketing:
		if not state_now == State.TWEENING and not platform_type == Platform_Type.Ray_V_Ball and not platform_type == Platform_Type.POLE and not platform_type == Platform_Type.ROPE:
			is_moving = true
			sly_rot.look_at(position - direction)
			var acceleration = 40
			var friction
			if state_now == State.AIR:
				acceleration = 80
				friction = true_left_stick_pressure * 20 / SPEED
				
			else:
				acceleration = 50
				friction = 1
			if not is_pickpocketing:
				
				if can_rotate:
					sly_container.rotate_y(lerp(sly_new.rotation.y, sly_rot.rotation.y, lerp_val * air_accel * acceleration * delta))
				velocity.x = lerp(velocity.x, direction.x * SPEED * SPEED_MULT * left_stick_pressure, lerp_val * friction * acceleration * air_accel * delta)
				velocity.z = lerp(velocity.z, direction.z * SPEED * SPEED_MULT * left_stick_pressure, lerp_val * friction * acceleration * air_accel * delta)
			### Rotates Sly's Tail to Direction
			$sly_container/SlyCooper_RigNoPhysics.ball_target.global_rotation.y = sly_rot.rotation.y + sly_container.global_rotation.y
			$sly_container/SlyCooper_RigNoPhysics.get_node("Ball Tail Root/Ball Anim").play("walk")
		
		$CameraOrigin/CameraArm/camera/CanvasLayer/RichTextLabel4.text = str(left_stick_pressure)
	else:
		is_moving = false
		velocity.x = lerp(velocity.x, 0.0, lerp_val * 45 * air_accel * delta)
		velocity.z = lerp(velocity.z, 0.0, lerp_val * 45 * air_accel * delta)
		$sly_container/SlyCooper_RigNoPhysics.get_node("Ball Tail Root/Ball Anim").play("rotate")
		

func jump():
	cam_y_follow = false
	platform_type = Platform_Type.NULL
	$jump_sound.pitch_scale = randf_range(0.7, 1)
	if do_big_jump == true:
		velocity.y = JUMP_VELOCITY * big_jump_mult
		sly_anim_tree.set("parameters/Jump_State/transition_request", "Floor_Jump")
		sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
	elif double_jump:
		coyote_timer.start(0.3)
		$Camtime.start(1)
		$jump_sound.volume_db = -35
		$jump_sound.play()
		if state_now == State.FLOOR or state_now == State.ON_PLATFORM:
			velocity.y = JUMP_VELOCITY + 0.75
			sly_anim_tree.set("parameters/Jump_State/transition_request", "Floor_Jump")
			sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
		if state_now == State.AIR:
			if can_wall:
				sly_anim_tree.set("parameters/Jump_State/transition_request", "Floor_Jump")
				velocity.y += JUMP_VELOCITY
			else:
				sly_anim_tree.set("parameters/Jump_State/transition_request", "W_Jump")
				if velocity.y > 4:
					velocity.y += JUMP_VELOCITY * 0.25
				elif velocity.y >= 0 and velocity.y <= 4:
					velocity.y += JUMP_VELOCITY * 0.55
				elif velocity.y < 0:
					velocity.y += JUMP_VELOCITY - 2.5
			sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
			#$sly_container/SlyCooper_RigNoPhysics.get_node("Ball Tail Root/Ball Anim").play("handle flip")
			
				
		double_jump = false
	do_big_jump = false

func high_jump():
	cam_y_follow = true
	platform_type = Platform_Type.NULL
	$jump_sound.pitch_scale = randf_range(0.7, 1)
	if state_now == State.FLOOR or state_now == State.TWEENING or state_now == State.ON_PLATFORM:
		if Global.power_ups >= 1:
			coyote_timer.start(0.3)
			$Camtime.start(1)
			$jump_sound.volume_db = -35
			$jump_sound.play()
			velocity.y = JUMP_VELOCITY * 1.645
			sly_anim_tree.set("parameters/Jump_State/transition_request", "Floor_Jump")
			sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
			double_jump = false
			Global.power_ups -= 1

func handle_jump_rot():
	#NOT WORKING WIP
	var forward_dir = -sly_container.global_transform.basis.z.normalized()
	var right_dir = sly_container.global_transform.basis.x.normalized()

	var forward_dot = forward_dir.dot(velocity.normalized())
	var right_dot = right_dir.dot(velocity.normalized())
	
	var threshold = 0.5
	
	var rot_dif = wrapf(rad_to_deg(sly_container.rotation.y - rotation.y), -180, 180)
	
	if abs(rot_dif) < 45:
		sly_anim_tree.set("parameters/Jump_State/transition_request", "W_Jump")
	elif rot_dif > 45 and rot_dif < 135:
		sly_anim_tree.set("parameters/Jump_State/transition_request", "D_Jump")
	elif rot_dif > -45 and rot_dif < -135:
		sly_anim_tree.set("parameters/Jump_State/transition_request", "A_Jump")
	else:
		sly_anim_tree.set("parameters/Jump_State/transition_request", "S_Jump")
	can_rotate = true

func pickpocket():
	$"Pickpocket Time".start(1)
	is_pickpocketing = true
	sly_anim_tree.set("parameters/Jump_State/transition_request", "Fight")
	sly_anim_tree.set("parameters/Jump_or_Move/request", 1)

func hit():
	sly_anim_tree.set("parameters/Jump_State/transition_request", "Punch")
	sly_anim_tree.set("parameters/Jump_or_Move/request", 1)

func manage_target_type():
	#SPEED_MULT = 0
	print("managing target type")
	if target == null:
		if can_wall:
			platform_type = Platform_Type.WALL
			air_anim = "pole"
			floor_anim = "pole"
		platform_type = Platform_Type.NULL
		return
	if target.is_in_group("Notch"):
		do_big_jump = true
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
		air_anim = "ray_v_ball"
		floor_anim = "ray_v_ball"
	print("platform type = ", platform_type)
	

func find_target_b():
	print("finding target b!")
	
	if distance_to_ball < 3 and velocity.y < 0:
		if target_b == null and can_ledge:
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
		elif distance_a> distance_b and not target_a == null:
			target = target_b
	print("target = ", target)
	if not target == null:
		move_to_target()
		

func move_to_target():
	state_now = State.TWEENING
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
				offset_num = 0.6
		manage_target_type()
		var final_offset = Vector3(0,offset_num,0)
		var tween_to_target = platform.global_transform.origin - global_transform.origin
		if platform_type == Platform_Type.ROPE:
			tween_to_target = platform.global_transform.origin - $"Movement Offset".global_transform.origin
		var tween_distance_to_target = tween_to_target.length()
		var x_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		var y_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		var z_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		if not sly_container_anim.current_animation == "spin":
			var target_position = platform.global_transform.origin + final_offset
			x_tween.tween_property(
				self,
				"position:x",
				platform.global_transform.origin.x,
				tween_distance_to_target / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			y_tween.tween_property(
				self,
				"position:y",
				platform.global_transform.origin.y,
				tween_distance_to_target / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_QUART)
			z_tween.tween_property(
				self,
				"position:z",
				platform.global_transform.origin.z,
				tween_distance_to_target / (SPEED * SPEED_MULT),
			).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			sly_anim_tree.set("parameters/Move_State/transition_request", "air")
			$AnimationPlayer.queue("RESET")
			if platform_type == Platform_Type.POINT:
				sly_container_anim.play("spin")
			if target == target_a:
				sly_anim_tree.set("parameters/Jump_State/transition_request", "Spin")
				sly_anim_tree.set("parameters/Jump_or_Move/request", 1)
	

func ledge_detect():
	can_ledge = false
	var hit_ray_h = ray_h.get_collision_point()
	var hit_ray_h1 = ray_h1.get_collision_point()
	var hit_ray_h2 = ray_h2.get_collision_point()
	var hit_ray_h3 = ray_h3.get_collision_point()
	var hit_ray_h_final = Vector3()
	
	var ray_h_collider = ray_h.get_collider()
	var ray_h1_collider = ray_h1.get_collider()
	var ray_h2_collider = ray_h2.get_collider()
	var ray_h3_collider = ray_h3.get_collider()
	
	var hit_ray_v = ray_v.get_collision_point()
	var offset = Vector3(0,4.75,0)
	
	if not ray_top.is_colliding() and not $sly_container/Ray_Top1.is_colliding() and not $sly_container/Ray_Top2.is_colliding() and not $sly_container/Ray_Top3.is_colliding():
		if ray_h.is_colliding() and not ray_h_collider.is_in_group("Player"):
			hit_ray_h_final = hit_ray_h
			can_ledge = true
		elif ray_h1.is_colliding() and not ray_h1_collider.is_in_group("Player"):
			hit_ray_h_final = hit_ray_h1
			can_ledge = true
		elif ray_h2.is_colliding() and not ray_h2_collider.is_in_group("Player"):
			hit_ray_h_final = hit_ray_h2
			can_ledge = true
		elif ray_h3.is_colliding() and not ray_h3_collider.is_in_group("Player"):
			hit_ray_h_final = hit_ray_h3
			can_ledge = true
	
	ray_v_holder.global_transform.origin = hit_ray_h_final + offset
	ray_v_ball.global_transform.origin = hit_ray_v
	$Ray_V_Container/Particle_Sparkle.global_transform.origin = hit_ray_v
	
	to_ray_ball = ray_v_ball.global_transform.origin - global_transform.origin
	distance_to_ball = to_ray_ball.length()
	if can_ledge:
		target_distance_manager()
		



func wall_detect():
	
	if is_on_floor() or state_now == State.ON_PLATFORM:
		$"Wall Cooldown".stop()
		can_wall_timer = true
		
	
	if not ray_h.is_colliding() and not ray_wall_top.is_colliding():
		can_wall = false
		can_wall_timer = true
	
	else:
		if $"Wall Time".is_stopped() and can_wall_timer == true and Input.is_action_pressed("ui_accept") and $"Wall Cooldown".time_left <= 0:
			$"Wall Time".start(0.65)
			can_wall = true
			$"Wall Cooldown".start(10)
		if $"Wall Time".time_left >= 0.01 and Input.is_action_just_released("ui_accept"):
			jump()
			double_jump = true
			$"Wall Time".stop()
		if $"Wall Time".time_left < 0.01:
			can_wall = false
			can_wall_timer = false
	
	if can_wall:
		if velocity.y >= -4.5:
			velocity.y = 4.5
		else:
			velocity.y += 4.5
	



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
			
	
func camera_smooth_follow(delta):
	var cam_offset = Vector3(0, 1.5, 0).rotated(Vector3.UP, camera_T)
	cam_speed = 350
	var cam_timer = clamp(delta * cam_speed / 20, 0, 1)
	var cam_to_player_x = abs(camera_parent.camera.global_transform.origin.x - global_transform.origin.x)
	var cam_to_player_y = abs(camera_parent.camera.global_transform.origin.y - global_transform.origin.y)
	var cam_to_player_z = abs(camera_parent.camera.global_transform.origin.z - global_transform.origin.z)
	var cam_distance = (cam_to_player_x + cam_to_player_y + cam_to_player_z) / 3
	var tform = sly_new.global_transform.origin + sly_new.global_transform.basis.z * 0.75
	var offsetform = sly_new.global_transform.origin + sly_new.global_transform.basis.z * 2
	$"Movement Offset".global_transform.origin.x = offsetform.x
	$"Movement Offset".global_transform.origin.y = offsetform.y
	$"Movement Offset".global_transform.origin.z = offsetform.z
	joystick_event()
	$Basis_Offset.global_transform.origin.x = lerp($Basis_Offset.global_transform.origin.x, tform.x, cam_timer / 15)
	$Basis_Offset.global_transform.origin.z = lerp($Basis_Offset.global_transform.origin.z, tform.z, cam_timer / 15)
	camera_parent.position.x = $Basis_Offset.global_transform.origin.x
	camera_parent.position.z = $Basis_Offset.global_transform.origin.z

#	if not $"CollisionShape3D/Cam Y Ray".is_colliding() or state_now != State.AIR or $sly_container/paraglider.visible == true:
#		if camtime.time_left <= 0:
#			camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 5)
#	elif $"CollisionShape3D/Cam Y Ray".is_colliding() and state_now == State.AIR and velocity.y < -9:
#		if camtime.time_left <= 0:
#			camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 8)

	if state_now == State.AIR:
		if $sly_container/paraglider.visible == true:
			camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 1.5)
		
		if $"CollisionShape3D/Cam Y Ray".is_colliding():
			if camtime.time_left <= 0:
				camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 1.5)
		else:
			if camtime.time_left <= 0 or velocity.y < -9:
				camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 1.5)
	else:
		camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 4)
	if cam_y_follow:
		camera_parent.position.y = lerp(camera_parent.global_transform.origin.y, global_transform.origin.y + 1.8, cam_timer / 1.5)

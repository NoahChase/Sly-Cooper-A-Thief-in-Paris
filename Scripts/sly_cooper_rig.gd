extends Node3D
@export var playerbody = CharacterBody3D
@onready var anim_tree = $AnimationTree

@onready var air_anim: String
@onready var locomotion_anim: String




@onready var move_state: String

@onready var locomotion_state: String
@onready var locomotion_oneshot: String

@onready var air_state: String
@onready var air_oneshot: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	anim_tree.set("parameters/floor_blend/blend_position", playerbody.blend_pos)
	anim_tree.set("parameters/ledge_blend/blend_position", playerbody.blend_pos)
	anim_tree.set("parameters/pole_blend/blend_position", playerbody.blend_pos)
	anim_tree.set("parameters/rope_blend/blend_position", playerbody.blend_pos)
	
	
	
	if playerbody.state_now == playerbody.State.FLOOR or playerbody.state_now == playerbody.State.ON_PLATFORM  or playerbody.state_now == playerbody.State.TWEENING:
		move_state = "locomotion"
		if playerbody.state_now == playerbody.State.FLOOR:
			locomotion_anim = "floor"
		#locomotionstate = floor
		#move_state = locomotion
		if playerbody.state_now == playerbody.State.ON_PLATFORM :
			if playerbody.platform_type == playerbody.Platform_Type.POINT:
				locomotion_anim = "point"
				#anim_tree.locomotion_state = point
			if playerbody.platform_type == playerbody.Platform_Type.POLE:
				locomotion_anim = "pole"
				#anim_tree.locomotion_state = pole
			if playerbody.platform_type == playerbody.Platform_Type.ROPE:
				locomotion_anim = "rope"
				#locomotion_state = rope
			if playerbody.platform_type == playerbody.Platform_Type.LEDGE:
				locomotion_anim = "ledge"
				#locomotion_state = ledge
			if playerbody.platform_type == playerbody.Platform_Type.Ray_V_Ball:
				locomotion_anim = "ray_v_ball"
				#locomotion_state = ray_v_ball
		
	if playerbody.state_now == playerbody.State.AIR:
		move_state = "air"
	
	
	anim_tree.set("parameters/Locomotion_State/transition_request", locomotion_anim)
	anim_tree.set("parameters/Air_State/transition_request", air_anim)
	anim_tree.set("parameters/Move_State/transition_request", move_state)


	#if signal.player jump: 
		#fire air_oneshot
		#fire locomotion_oneshot



	##must do before fire jump

	#if signal.do_wjump
		#wjump

	#if signal.do_sjump
		#sjump

	#if signal.do_ajump
		#ajump

	#if signal.do_djump
		#djump

	#if signal.do_spin
		#spin

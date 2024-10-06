extends Node3D

@export var tail_targets = Node3D

@onready var skeleton = %GeneralSkeleton
@onready var bone_tail_001 = skeleton.find_bone("Tail.001")
@onready var bone_tail_002 = skeleton.find_bone("Tail.002")
@onready var bone_tail_003 = skeleton.find_bone("Tail.003")
@onready var bone_tail_004 = skeleton.find_bone("Tail.004")
@onready var bone_tail_005 = skeleton.find_bone("Tail.005")
@onready var bone_tail_006 = skeleton.find_bone("Tail.006")
@onready var bone_tail_007 = skeleton.find_bone("Tail.007")
@onready var bone_tail_008 = skeleton.find_bone("Tail.008")


@onready var ball_root_node = $"Ball Tail Root"
@onready var ball_target = $"Ball Tail Root/Ball Tail Target"
@onready var ball_1 = $"Ball Tail Root/Ball Tail 1"
@onready var ball_8 = $"Ball Tail Root/Ball Tail 8"
@onready var ball_7 = $"Ball Tail Root/Ball Tail 7"
@onready var ball_6 = $"Ball Tail Root/Ball Tail 6"
@onready var ball_5 = $"Ball Tail Root/Ball Tail 5"
@onready var ball_4 = $"Ball Tail Root/Ball Tail 4"
@onready var ball_3 = $"Ball Tail Root/Ball Tail 3"
@onready var ball_2 = $"Ball Tail Root/Ball Tail 2"

@onready var ball_1_cnt = $"Ball Tail Root/Ball Tail 1/Node3D/cnt"
@onready var ball_8_cnt = $"Ball Tail Root/Ball Tail 8/Node3D/cnt"
@onready var ball_7_cnt = $"Ball Tail Root/Ball Tail 7/Node3D/cnt"
@onready var ball_6_cnt = $"Ball Tail Root/Ball Tail 6/Node3D/cnt"
@onready var ball_5_cnt = $"Ball Tail Root/Ball Tail 5/Node3D/cnt"
@onready var ball_4_cnt = $"Ball Tail Root/Ball Tail 4/Node3D/cnt"
@onready var ball_3_cnt = $"Ball Tail Root/Ball Tail 3/Node3D/cnt"

# Called when the node enters the scene tree for the first time.
func _ready():

	$"Ball Tail Root/Ball Anim".play("RESET")
	$metarig/GeneralSkeleton/SkeletonIK3D.start()
	$"metarig/GeneralSkeleton/Tail 2 IK".start()
	$"metarig/GeneralSkeleton/Tail 3 IK".start()
	$"metarig/GeneralSkeleton/Tail 4 IK".start()
	$"metarig/GeneralSkeleton/Tail 5 IK".start()
	$"metarig/GeneralSkeleton/Tail 6 IK".start()
	$"metarig/GeneralSkeleton/Tail 7 IK".start()
	

func _physics_process(delta):
	ball_target.rotation.y = clamp(ball_target.rotation.y, deg_to_rad(-90), deg_to_rad(90))
	ball_target.rotation.x = clamp(ball_target.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	ball_1.rotation = lerp(ball_1.rotation, -ball_target.rotation, 0.9)
	ball_8.rotation = lerp(ball_8.rotation, ball_1.rotation + (ball_target.rotation / 1.5), 0.9)
	ball_7.rotation = lerp(ball_7.rotation, ball_8.rotation + (ball_1.rotation), 0.15)
	ball_6.rotation = lerp(ball_6.rotation, ball_7.rotation + (ball_8.rotation), 0.1125)
	ball_5.rotation = lerp(ball_5.rotation, ball_6.rotation + (ball_7.rotation), 0.1125)
	ball_4.rotation = lerp(ball_4.rotation, ball_5.rotation + (ball_6.rotation / 5), 0.075)
	ball_3.rotation = lerp(ball_3.rotation, ball_4.rotation + (ball_5.rotation / 10), 0.05)
	ball_2.rotation = lerp(ball_2.rotation, ball_3.rotation + (ball_4.rotation / 5), 0.0125)

	ball_target.global_position = lerp(ball_target.global_position, $metarig/GeneralSkeleton/BoneAttachment3D2.global_position, 0.9)
	ball_1.position = lerp(ball_1.position, -ball_target.position, 0.9)
	ball_8.global_position = lerp(ball_8.global_position, ball_1_cnt.global_position + (ball_target.position / 1.5), 0.9)
	ball_7.global_position = lerp(ball_7.global_position, ball_8_cnt.global_position + (ball_1.position), 0.15)
	ball_6.global_position = lerp(ball_6.global_position, ball_7_cnt.global_position + ball_8.position, 0.1125)
	ball_5.global_position = lerp(ball_5.global_position, ball_6_cnt.global_position + ball_7.position, 0.1125)
	ball_4.global_position = lerp(ball_4.global_position, ball_5_cnt.global_position + (ball_6.position / 5), 0.075)
	ball_3.global_position = lerp(ball_3.global_position, ball_4_cnt.global_position + (ball_5.position / 10), 0.075)
	ball_2.global_position = lerp(ball_2.global_position, ball_3_cnt.global_position + (ball_4.position / 5), 0.075)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	#var t_8 = skeleton.get_bone_global_pose(bone_tail_008)
	#var t_7 = skeleton.get_bone_global_pose(bone_tail_007)
	#var t_6 = skeleton.get_bone_global_pose(bone_tail_006)
	#var t_5 = skeleton.get_bone_global_pose(bone_tail_005)
	#var t_4 = skeleton.get_bone_global_pose(bone_tail_004)
	#var t_3 = skeleton.get_bone_global_pose(bone_tail_003)
	#var t_2 = skeleton.get_bone_global_pose(bone_tail_002)
	#var t_1 = skeleton.get_bone_global_pose(bone_tail_001)
	
	
	#var pose_008 = 0
	#var pose_001 = t_3.basis.get_euler().y
	#var new_rotation = lerp(pose_008, pose_001, 0.15)
	
	#var tail_offset_x = t_8.origin.x * 1.5
	#var tail_offset_y = t_8.origin.y - 0.92 / 2
	#var tailrot_offset_y = t_8.basis.get_euler().x
	
	#t_8.basis.get_euler().y = lerp(t_8.basis.get_euler().y, t_1.basis.get_euler().y + tailrot_offset_y, 0.75)
	#t_8.origin.x = lerp(t_8.origin.x, t_1.origin.x + tail_offset_x, 0.75 * 2)
	#t_8.origin.y = lerp(t_8.origin.y, (t_1.origin.y + tail_offset_y), 0.75)
	
	#t_8.basis.get_euler().x = lerp(t_8.basis.get_euler().x, t_1.basis.get_euler().x + tailrot_offset_y, 0.75)
	#skeleton.set_bone_global_pose_override(bone_tail_008, t_8, 1.0, true)
	
	#t_7.origin.x = lerp(t_7.origin.x, t_8.origin.x + tail_offset_x / 2, 0.6 * 2)
	#t_7.origin.y = lerp(t_7.origin.y, (t_8.origin.y + tail_offset_y) / 2, 0.6 * 1.5)
	
	#t_6.basis.get_euler().x = lerp(t_6.basis.get_euler().x, t_7.basis.get_euler().x + tailrot_offset_y, 0.45 * 1.5)
	#skeleton.set_bone_global_pose_override(bone_tail_007, t_7, 1.0, true)
	
	#t_6.origin.x = lerp(t_6.origin.x, t_7.origin.x + tail_offset_x / 4, 0.45 * 2)
	#t_6.origin.y = lerp(t_6.origin.y, (t_7.origin.y + tail_offset_y) / 1.8, 0.45 * 2)
	
	#t_6.basis.get_euler().x = lerp(t_6.basis.get_euler().x, t_7.basis.get_euler().x + tailrot_offset_y, 0.45 * 2)
	#skeleton.set_bone_global_pose_override(bone_tail_006, t_6, 1.0, true)
	
	#t_5.origin.x = lerp(t_5.origin.x, t_6.origin.x - tail_offset_x / 4, 0.3 * 2)
	#t_5.origin.y = lerp(t_5.origin.y, (t_6.origin.y + tail_offset_y + 0.0125) / 1.7, 0.3 * 2)
	
	#t_5.basis.get_euler().x = lerp(t_5.basis.get_euler().x, t_6.basis.get_euler().x + tailrot_offset_y, 0.3 * 2)
	#skeleton.set_bone_global_pose_override(bone_tail_005, t_5, 1.0, true)
	
	#t_4.origin.x = lerp(t_4.origin.x, t_5.origin.x - tail_offset_x / 4, 0.15 * 2)
	#t_4.origin.y = lerp(t_4.origin.y, (t_5.origin.y + tail_offset_y + 0.025) / 1.8, 0.15 * 2)
	
	#t_4.basis.get_euler().x = lerp(t_4.basis.get_euler().x, t_5.basis.get_euler().x + tailrot_offset_y, 0.15 * 2)
	#skeleton.set_bone_global_pose_override(bone_tail_004, t_4, 1.0, true)
	
	#t_3.origin.x = lerp(t_3.origin.x, t_4.origin.x - tail_offset_x / 3, 0.1125 * 2)
	#t_3.origin.y = lerp(t_3.origin.y, (t_4.origin.y + tail_offset_y + 0.05) / 1.9, 0.1125 * 2)
	
	#t_3.basis.get_euler().x = lerp(t_3.basis.get_euler().x, t_4.basis.get_euler().x + tailrot_offset_y, 0.1125 * 2)
	#skeleton.set_bone_global_pose_override(bone_tail_003, t_3, 1.0, true)
	
	#t_2.origin.x = lerp(t_2.origin.x, t_3.origin.x - tail_offset_x, 0.075 * 2)
	#t_2.origin.y = lerp(t_3.origin.y, (t_3.origin.y + tail_offset_y + 0.05) / 2, 0.075 * 2)
	
	#t_2.basis.get_euler().y = lerp(t_2.basis.get_euler().y, t_3.basis.get_euler().y + tailrot_offset_y, 0.075 * 2)
	#skeleton.set_bone_global_pose_override(bone_tail_003, t_3, 1.0, true)


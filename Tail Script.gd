extends Node3D

@onready var target = $"Motion Instantiater"
@onready var tail_root = $"Tail Root"
@onready var tail_bone_1 = $"Tail 1"
@onready var tail_bone_2 = $"Tail 2"
@onready var tail_bone_3 = $"Tail 3"
@onready var tail_bone_4 = $"Tail 4"
@onready var tail_bone_5 = $"Tail 5"
@onready var tail_bone_6 = $"Tail 6"
@onready var tail_bone_7 = $"Tail 7"

@onready var tr_cnt = $"Tail Root/Arms/connector"
@onready var t1_cnt = $"Tail 1/Arms/connector"
@onready var t2_cnt = $"Tail 2/Arms/connector"
@onready var t3_cnt = $"Tail 3/Arms/connector"
@onready var t4_cnt = $"Tail 4/Arms/connector"
@onready var t5_cnt = $"Tail 5/Arms/connector"
@onready var t6_cnt = $"Tail 6/Arms/connector"
@onready var t7_cnt = $"Tail 7/Arms/connector"

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Motion Instantiater Animation Player".play("rotation")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	### Rotation ###
	tail_root.rotation = lerp(tail_root.rotation, target.rotation, 0.3)
	tail_bone_1.rotation = lerp(tail_bone_1.rotation, tail_root.rotation + (target.rotation), 0.15)
	tail_bone_2.rotation = lerp(tail_bone_2.rotation, tail_bone_1.rotation + (target.rotation / 2), 0.1125)
	tail_bone_3.rotation = lerp(tail_bone_3.rotation, tail_bone_2.rotation + (target.rotation / 3), 0.075)
	tail_bone_4.rotation = lerp(tail_bone_4.rotation, tail_bone_3.rotation + (target.rotation / 4), 0.075)
	tail_bone_5.rotation = lerp(tail_bone_5.rotation, tail_bone_4.rotation + (target.rotation / 5), 0.075)
	tail_bone_6.rotation = lerp(tail_bone_6.rotation, tail_bone_5.rotation + (target.rotation / 6), 0.075)
	tail_bone_7.rotation = lerp(tail_bone_7.rotation, tail_bone_6.rotation + (target.rotation / 7), 0.075)
	
	### Translation ###
	tail_root.global_position = lerp(tail_root.global_position, target.global_position, 0.3)
	tail_bone_1.global_position = lerp(tail_bone_1.global_position, tail_root.global_position + tr_cnt.global_position + (tail_root.global_position), 0.15)
	tail_bone_2.global_position = lerp(tail_bone_2.global_position, tail_bone_1.global_position + tr_cnt.global_position + (tail_root.global_position / 2), 0.1125)
	tail_bone_3.global_position = lerp(tail_bone_3.global_position, tail_bone_2.global_position + tr_cnt.global_position + (tail_root.global_position / 3), 0.075)
	tail_bone_4.global_position = lerp(tail_bone_4.global_position, tail_bone_3.global_position + tr_cnt.global_position + (tail_root.global_position / 4), 0.075)
	tail_bone_5.global_position = lerp(tail_bone_5.global_position, tail_bone_4.global_position + tr_cnt.global_position + (tail_root.global_position / 5), 0.075)
	tail_bone_6.global_position = lerp(tail_bone_6.global_position, tail_bone_5.global_position + tr_cnt.global_position + (tail_root.global_position / 6), 0.075)
	tail_bone_7.global_position = lerp(tail_bone_7.global_position, tail_bone_6.global_position + tr_cnt.global_position + (tail_root.global_position / 7), 0.075)

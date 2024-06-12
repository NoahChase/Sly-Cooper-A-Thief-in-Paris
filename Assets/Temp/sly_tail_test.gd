extends Node3D
@onready var tail = $"Tail Physics Targets"
@onready var sly = $SlyCooper_RigNoPhysics

# Called when the node enters the scene tree for the first time.
func _ready():
	sly.tail_root_ik.target_node = tail.target
	sly.tail_2_ik.target_node = tail.tail_root
	sly.tail_3_ik.target_node = tail.tail_bone_1
	sly.tail_4_ik.target_node = tail.tail_bone_2
	sly.tail_5_ik.target_node = tail.tail_bone_3
	sly.tail_6_ik.target_node = tail.tail_bone_4
	sly.tail_7_ik.target_node = tail.tail_bone_5
	
	sly.tail_root_ik.start()
	sly.tail_2_ik.start()
	sly.tail_3_ik.start()
	sly.tail_4_ik.start()
	sly.tail_5_ik.start()
	sly.tail_6_ik.start()
	sly.tail_7_ik.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

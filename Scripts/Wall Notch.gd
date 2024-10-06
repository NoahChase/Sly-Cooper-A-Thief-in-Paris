@tool
extends Node3D

@onready var test_ball = $"Test Ball"
@onready var target = null

@export var magnet_force: float
@export var jump_mult: float
@export var area_height: float
@export var area_width: float
@export var area_pos_y: float

func _ready():
	$Area3D/CollisionShape3D.shape.height = area_height
	$Area3D/CollisionShape3D.shape.radius = area_width
	$Area3D/CollisionShape3D.position.y = area_pos_y
func _process(delta):
	if not target == null:
		if target.state_now == target.State.AIR:
			magnetize_target()
			
		if not target.do_big_jump == true:
			if test_ball == target.target:
				target.do_big_jump == true
	else:
		pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		target.big_jump_mult = jump_mult


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		target = null

func magnetize_target():
		var direction = (test_ball.global_transform.origin - target.global_transform.origin).normalized()
		target.velocity += direction * magnet_force

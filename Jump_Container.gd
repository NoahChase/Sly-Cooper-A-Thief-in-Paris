extends Node3D

@onready var collision_shape_3d = $Area3D/CollisionShape3D

@export var jump = 35
@export var has_mesh = false
@export var mesh = Node3D
var target

func _ready():
	pass

func _process(delta):
	if target != null:
		target.velocity.y = jump
		if has_mesh:
			mesh.anim.play("bounce")


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		target = null

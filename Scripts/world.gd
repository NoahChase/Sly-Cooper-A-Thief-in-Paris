extends Node3D
@onready var spawn_point = $"Spawn Point"
@onready var target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_border_body_entered(body):
	pass # Replace with function body.


func _on_border_body_exited(body):
	if body.is_in_group("Player"):
		target = body
		target.position = spawn_point.position

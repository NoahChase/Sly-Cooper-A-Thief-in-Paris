extends Node3D

@onready var anim = $AnimationPlayer

var shoot = true

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if shoot:
		if not anim.current_animation == "recoil":
			anim.queue("recoil")
			anim.queue("reset")
		if anim.current_animation == "recoil":
			var bullet_scene : PackedScene = load("res://Assets/Obj Scenes/bullet.tscn")
			var bullet = bullet_scene.instantiate()
			self.add_child(bullet)
			bullet.global_position = global_position

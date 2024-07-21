extends Node3D

@onready var anim = $AnimationPlayer

var hp = 1
var shoot = true

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if shoot:
		if not anim.current_animation == "recoil":
			anim.queue("recoil")
			anim.queue("reset")
		if anim.current_animation == "reset":
			hp = 1
		if anim.current_animation == "recoil" and hp == 1:
			hp = 0
		if hp == 0:
			$"Gun Audio".pitch_scale = randf_range(0.75, 1)
			$"Gun Audio".play()
			var bullet_scene : PackedScene = load("res://Assets/Obj Scenes/bullet.tscn")
			var bullet = bullet_scene.instantiate()
			self.add_child(bullet)
			bullet.global_position = global_position


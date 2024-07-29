extends Node3D

@onready var anim = $AnimationPlayer
@onready var bullet_scene : PackedScene = load("res://Assets/Obj Scenes/bullet.tscn")

var shoot = true
var bullet_chambered = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shoot:
		if not anim.current_animation == "shoot":
			anim.queue("shoot")
		
		if anim.current_animation == "reset":
			bullet_chambered = true
		
		if anim.current_animation == "shoot":
			bullet_chambered = false
		
		if bullet_chambered == false:
			$"Gun Audio".pitch_scale = randf_range(0.75, 1)
			$"Gun Audio".play()
			var bullet = bullet_scene.instantiate()
			self.add_child(bullet)
			bullet.global_position = $muzzle.global_position
			anim.play("reset")

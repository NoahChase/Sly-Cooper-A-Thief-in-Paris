extends Node3D
@onready var clink = $Clink
@onready var timer = $Clink_Timer
@onready var clink_count = 1
@onready var target
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if clink_count == 0:
		if not $Break.is_playing():
			_play_anim()
			queue_free()
	else:
		if timer.is_stopped():
			timer.start(0.625)
			print("timer started")
			clink.stop()
			if not clink.is_playing():
				print("clink played")
				clink.pitch_scale = randf_range(0.9, 1.1)
				clink.play()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		target.bottle_number += 1
		$Break.play()
		$bottle.visible = false
		$GPUParticles3D.emitting = true
		clink_count = 0
		
func _play_anim():
	pass

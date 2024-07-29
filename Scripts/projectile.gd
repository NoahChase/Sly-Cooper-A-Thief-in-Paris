extends Node3D

@onready var shoot
@onready var hp = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position -= transform.basis.z * 25 * delta
	if $Timer.is_stopped():
		$Timer.start(10)
	if $Timer.time_left == 0.0:
		queue_free()
	if $RayCast3D.is_colliding():
		var col = $RayCast3D.get_collider()
		if not col.is_in_group("Player"):
			print("bullet ray collided")
			queue_free()
	


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player") and hp == 1:
		print("player hit")
		Global.health -= 1
		hp = 0
		var player_position = body.global_transform.origin
		var bullet_position = self.global_transform.origin
		# Calculate the direction to look at (only on the Y axis)
		var direction = (bullet_position - player_position).normalized()
		direction.y = 0  # Ignore the y component to look at only on the y-axis
		# Calculate the angle to rotate towards
		var angle = atan2(direction.x, direction.z)
		# Set the player's rotation on the y-axis
		body.sly_container.rotation.y = angle
		if body.state_now == body.State.FLOOR:
			body.velocity.y += body.JUMP_VELOCITY
			body.velocity -= self.global_transform.basis.z.normalized() * 30
		else:
			body.velocity = -self.global_transform.basis.z.normalized() * 15
			body.cam_y_follow = true
		body.player_hit = true
	queue_free()

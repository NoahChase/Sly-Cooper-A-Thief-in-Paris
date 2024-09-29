extends CharacterBody3D

enum {IDLE, CHASE, SEARCH, SHOOT, HIT, STUNNED}

const SPEED = 1.5
const JUMP_VELOCITY = 4

@onready var spotlight = $"Enemy Container/Spotlight Detection"
@onready var nav_agent = $NavigationAgent3D
@onready var colshape = $CollisionShape3D
@onready var target
@onready var new_nav_point = Node3D
@onready var prev_nav_point = Node3D
@onready var nav_distance = 0
@onready var SPEED_MULT = 1
@onready var body_found_target = false
@onready var target_in_range = false
@onready var heard_enemy = false
@onready var enemy_target
@onready var enemies = []
@onready var enemies_in_range = []
@onready var do_180 = false

@export var nav_parent: Node3D = null

var state = IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var nav_rng = RandomNumberGenerator.new()
var nav_rng_int

func _ready():
	nav_rng = RandomNumberGenerator.new()
	new_nav_point = nav_parent.get_node("Point 1")

func _process(delta):
	if spotlight.player_detected and state != CHASE:
		#print("enemy chase 1")
		target = spotlight.target
		if target.is_in_group("Player"):
			if enemies.size() > 0:
				hear_enemy_target()
			do_chase()
	

func _physics_process(delta):
	var direction = Vector3()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if not new_nav_point == null:
		nav_distance = global_transform.origin - new_nav_point.global_transform.origin
		if nav_distance.length() < 2:
			gen_nav_rng()
	if state == CHASE:
		if $AnimationPlayer.current_animation == "180 alert":
			$AnimationPlayer.stop()
		$"Enemy Container/searchmesh".visible = false
		$"Enemy Container/Arms".visible = true
		SPEED_MULT = 2.5
		$"Enemy Container/Gun".shoot = true
		$"Enemy Container/Gun".look_at(spotlight.get_node("TestMesh").global_transform.origin)
		if not spotlight.player_detected:
			spotlight.target = target
			spotlight.player_detected = true
		rotate_y(deg_to_rad(spotlight.look_at_player.rotation.y * 4))
		nav_agent.target_position = target.global_position
	if state == SEARCH:
		if $AnimationPlayer.current_animation == "180 alert":
			$AnimationPlayer.stop()
		$"Enemy Container/searchmesh".visible = true
		SPEED_MULT = 3
		$"Enemy Container/Gun".shoot = false
		$"Enemy Container/Gun".look_at(spotlight.get_node("TestMesh").global_transform.origin)
		rotate_y(deg_to_rad(spotlight.look_at_player.rotation.y * 4))
		nav_agent.target_position = target.global_position
		var search_nav_distance = global_transform.origin - target.global_transform.origin
		if search_nav_distance.length() < 5:
			do_idle()
			if enemies_in_range.size() > 0:
				hear_enemy_in_range()
		elif search_nav_distance.length() > 40:
			do_idle()
	if state == IDLE:
		if enemies.size() > 0:
			hear_enemy_target()
		if not target == null:
			if target_in_range and target.SPEED_MULT == 1.7:
				var search_nav_distance = global_transform.origin - target.global_transform.origin
				if search_nav_distance.length() < 12:
					if not $AnimationPlayer.current_animation == "180 alert":
						$AnimationPlayer.play("180 alert")
				#do_chase()
		$"Enemy Container/searchmesh".visible = false
		$"Enemy Container/Arms".visible = false
		$"Enemy Container/Gun".shoot = false
		SPEED_MULT = 0.9
		var target_rotation = global_transform.looking_at(nav_agent.get_next_path_position(), Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_rotation, 2 * delta)
		nav_agent.target_position = new_nav_point.global_position
		
	if not $AnimationPlayer.current_animation == "180 alert":
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * SPEED * SPEED_MULT, 4 * delta)
		move_and_slide()
	

func gen_nav_rng():
	nav_rng_int = nav_rng.randi_range(1, 5)
	if nav_rng_int == 1:
		new_nav_point = nav_parent.get_node("Point 1")
	if nav_rng_int == 2:
		new_nav_point = nav_parent.get_node("Point 2")
	if nav_rng_int == 3:
		new_nav_point = nav_parent.get_node("Point 3")
	if nav_rng_int == 4:
		new_nav_point = nav_parent.get_node("Point 4")
	if nav_rng_int == 5:
		new_nav_point = nav_parent.get_node("Point 5")
	print(nav_rng_int)
	

func hear_enemy_target():
	for enemy in enemies:
		# follow enemy if they have a target, if they don't abandon it. 
		if target == null:
			if enemy.target != null and enemy.state == CHASE:
				heard_enemy = true
				enemy_target = enemy.target
				target = enemy
				do_search()
			else:
				do_idle()
				heard_enemy = false
				enemy_target = null
			

func hear_enemy_in_range():
	for enemy_in_range in enemies_in_range:
		if target == null or state != CHASE:
			if enemy_in_range.target != null and enemy_in_range.target.is_in_group("Player") and enemy_in_range.state == CHASE and target_in_range:
				target = enemy_in_range.target
				#change to "do_180_turn" and "alert = true"
				do_chase()
			else:
				do_idle()
				

func do_chase():
	spotlight.target = target
	state = CHASE
func do_search():
	spotlight.target = target
	state = SEARCH
func do_idle():
	state = IDLE
	spotlight.target = null
	target = null
	

func _on_close_detection_area_body_entered(body):
	if body.is_in_group("Player"):
#		body_found_target = true
		target = body
		do_chase()
func _on_close_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		body_found_target = false
		#target = null
func _on_melee_area_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.append(body)
func _on_melee_area_body_exited(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.erase(body)
func _on_med_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		target_in_range = true
func _on_med_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		target_in_range = false
		if spotlight.target == body:
			spotlight.target = null
		target != body
		do_idle()
func _on_far_detection_area_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies.append(body)
		print("enemy added")
func _on_far_detection_area_body_exited(body):
	if body.is_in_group("Enemy"):
		enemies.erase(body)

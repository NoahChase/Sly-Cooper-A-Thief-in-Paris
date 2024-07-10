extends CharacterBody3D

enum {IDLE, CHASE, SEARCH, SHOOT, HIT, STUNNED}

const SPEED = 1.5
const JUMP_VELOCITY = 4.25

@onready var spotlight = $"Spotlight Detection"
@onready var nav_agent = $NavigationAgent3D
@onready var target
@onready var new_nav_point = Node3D
@onready var prev_nav_point = Node3D
@onready var nav_distance = 0
@onready var SPEED_MULT = 1
@onready var body_found_target = false

@export var nav_parent: Node3D = null

var state = IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var nav_rng = RandomNumberGenerator.new()
var nav_rng_int

func _ready():
	nav_rng = RandomNumberGenerator.new()
	new_nav_point = nav_parent.get_node("Point 1")

func _process(delta):
	if spotlight.player_detected == true:
		target = spotlight.target
		### If distance is close, do close combat state, else chase
		state = CHASE
	elif body_found_target == true:
		#spotlight.enemy_has_target = true
		spotlight.target = target
		### If distance is close, do close combat state, else chase
		state = CHASE
	else:
		state = IDLE
	

func _physics_process(delta):
	var direction = Vector3()
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not new_nav_point == null:
		nav_distance = global_transform.origin - new_nav_point.global_transform.origin
		if nav_distance.length() < 1:
			gen_nav_rng()
	
	if state == CHASE:
		### Movement
		if spotlight.player_detected == false:
			state = IDLE
		SPEED_MULT = 2.5
		$"Gun".shoot = true
		$"Gun".look_at(spotlight.get_node("TestMesh").global_transform.origin)
		rotate_y(deg_to_rad(spotlight.look_at_player.rotation.y * 10))
		nav_agent.target_position = target.global_position
		### Fire Gun While Chasing
	if state == IDLE:
		$"Gun".shoot = false
		SPEED_MULT = 1
		var target_rotation = global_transform.looking_at(nav_agent.get_next_path_position(), Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_rotation, 2 * delta)
		nav_agent.target_position = new_nav_point.global_position
	
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


func _on_close_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		body_found_target = true
		target = body


func _on_close_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		body_found_target = false
		#target = null

extends Node3D

@export var drop_health = true
@export var drop_coin = true

@onready var target

var coin_rng = RandomNumberGenerator.new()
var coin_rng_int
var hp = 1

signal spawn_loot(pos)

func _ready():
	self.connect("spawn_loot", Callable(self, "_on_spawn_loot"))

func _physics_process(delta):
	if not target == null:
		#spawn_loot.emit(global_position)
		if target.is_pickpocketing and hp == 1:
			spawn_loot.emit(global_position)
		if not target.is_pickpocketing:
			hp = 1
	else: hp = 1
			
		

func _on_spawn_loot(pos):
	var coin_scene : PackedScene = load("res://Assets/Obj Scenes/coin.tscn")
	coin_rng_int = coin_rng.randi_range(2, 6)
	for i in range(coin_rng_int):
		var coin = coin_scene.instantiate()
		self.add_child(coin)
		coin.position = pos
		coin.add_to_group("spawned_by_this_node")
	hp = 0


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		target = null

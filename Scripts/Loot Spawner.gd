extends Node3D

@export var drop_health = true
@export var drop_coin = true

var coin_rng = RandomNumberGenerator.new()
var coin_rng_int

signal spawn_loot(pos)

func _ready():
	self.connect("spawn_loot", Callable(self, "_on_spawn_loot"))

func _physics_process(delta):
	if $Timer.time_left == 0:
		spawn_loot.emit(global_position)
		$Timer.start(3)
		

func _on_spawn_loot(pos):
	var coin_scene : PackedScene = load("res://Assets/Obj Scenes/coin.tscn")
	coin_rng_int = coin_rng.randi_range(1, 3)
	for i in range(coin_rng_int):
		var coin = coin_scene.instantiate()
		self.add_child(coin)
		coin.position = pos
		coin.add_to_group("spawned_by_this_node")

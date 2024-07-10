extends Node

const max_health = 6
const max_power_ups = 3

var coins = 0
var health = 6
var power_ups = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		get_tree().quit()
	if power_ups <= 0:
		pass
	if coins >= 100:
		if health < max_health:
			health += 1
			coins -= 100
		if power_ups < max_power_ups:
			power_ups += 1
			coins -= 100
	if health > max_health: health = max_health
	if power_ups > max_power_ups: power_ups = max_power_ups
	if coins < 0: coins = 0

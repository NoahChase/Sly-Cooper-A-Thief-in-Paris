extends StaticBody3D

@onready var platform = $platform
@onready var mesh = $mesh
@onready var is_selected = false
@onready var move_forward = false
@onready var move_backward = false
@onready var target

@export var mesh_visible = false

func _ready():
	if mesh_visible == true:
		mesh.visible = true
	else:
		mesh.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



#on area body entered()
	#if player.target == self:
		#if body type == player:
			#player.is_on_target = true

#on area body exited()
	#if player.target == self:
		#if body type == player:
			#player.is_on_target = false

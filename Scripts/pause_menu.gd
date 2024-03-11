extends Control
@onready var margin_container = $MarginContainer
@onready var animation_player = $AnimationPlayer
@onready var margin_container_2 = $MarginContainer2

func _ready():
	pause()
	animation_player.play("RESET")

func play():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	margin_container.visible = false
	margin_container_2.visible = false
	animation_player.play_backwards("blur")
	
func pause():
	margin_container.visible = true
	margin_container_2.visible = false
	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		animation_player.play("blur")
	else:
		animation_player.play_backwards("pause_to_controls")

func controls():
	if margin_container.visible == true:
		animation_player.play("pause_to_controls")
		margin_container.visible = false
		margin_container_2.visible = true
	else:
		pause()

func testEsc():
	if Input.is_action_just_pressed("ESC") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("ESC") or Input.is_action_just_pressed("ui_accept") and get_tree().paused:
		play()
	elif Input.is_action_just_pressed("controller_select") and get_tree().paused:
		controls()
	elif Input.is_action_just_pressed("controller_home") and get_tree().paused:
		get_tree().quit()

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	play()

func _on_controls_pressed():
	controls()

func _on_controls_back_pressed():
	pause()
	
func _process(delta):
	testEsc()


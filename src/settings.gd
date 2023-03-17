extends Control

onready var player = $player

onready var glow = $layer/glow

onready var env = preload("res://game.tres")

var opened = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("esc") and opened == false:
		menu(0)
	elif Input.is_action_just_pressed("esc") and opened == true:
		menu(1)

	if opened == true:
		get_tree().paused = true
	else:
		get_tree().paused = false

	if env.glow_enabled == true:
		glow.pressed = true
	else:
		glow.pressed = false

func menu(type):
	if type == 0:
		player.play("setting")
		opened = true
	else:
		player.play_backwards("setting")
		opened = false

func _on_glow_toggled(button_pressed):
	if button_pressed == true:
		env.glow_enabled = true
		
	else:
		env.glow_enabled = false

func _on_sound_toggled(_button_pressed):
	pass # Replace with function body.

func _on_exit_pressed():
	player.play_backwards("setting")
	opened = false

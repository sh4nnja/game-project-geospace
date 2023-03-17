extends Control

onready var transition = $transition
onready var settings = $settings

func _on_start_pressed():
	transition.transition("res://scn/tutorial/tutorial.tscn")

func _on_settings_pressed():
	settings.menu(0)

extends Control

onready var transition = $transition

func _on_tutorialDone_pressed():
	transition.transition("res://scn/game/menu.tscn")


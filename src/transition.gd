extends Control

onready var player = $player

var scene
var isNull = false

func transition(scn):
	if scn == null:
		player.play_backwards("fade")
		isNull = true
	else:
		player.play("fade")
		scene = scn
		
func _on_player_animation_finished(_anim_name):
	if isNull == false:
		var _changescn = get_tree().change_scene(scene)

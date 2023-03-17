extends Node2D

onready var CT = preload("res://obj/fx/combatText/combatText.tscn")

var spawnNew = false
var offset = 120


var duration = 1
var spread = PI / 10

func showValue(value, crit = false):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var ctInst = CT.instance()
	get_node("/root/menu/game/rocks").add_child(ctInst)
	ctInst.showValue(str(value), duration, crit)
	ctInst.get_child(0).rect_rotation = 0
	ctInst.get_child(0).rect_position = Vector2(global_position.x + rng.randi_range(-offset, offset), global_position.y + rng.randi_range(-offset, offset))
	

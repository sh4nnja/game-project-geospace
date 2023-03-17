extends Node

onready var statsText = $UILayer/ui/statsText

onready var env = preload("res://game.tres")
onready var mapTween = $game/map/mapTween
onready var rWalls = $UILayer/ui/reachedWalls

onready var animPlayer = $animPlayer

var glowEnabled 

var ship 
var dLock = false

var invi = Color(1, 1, 1, 0)
var notInvi = Color(1, 1, 1, 1)

func _ready():
	env.adjustment_saturation = 1
	rockSpawners(true)

func keyBoardSettings():
	if Input.is_action_just_pressed("offGlow") and env.glow_enabled == false:
		env.glow_enabled = true
	elif Input.is_action_just_pressed("offGlow") and env.glow_enabled == true:
		env.glow_enabled = false
		
	if env.glow_enabled == false:
		glowEnabled = false
	else:
		glowEnabled = true
		
	if Input.is_action_just_pressed("offDebug") and statsText.visible == false:
		statsText.show()
	elif Input.is_action_just_pressed("offDebug") and statsText.visible == true:
		statsText.hide()

func _physics_process(_delta):
	statsText.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n" + "\n" + "Debug (Press 3 to Toggle)" + "\n" + "Glow (Press 1 to Toggle): " + str(glowEnabled) + "\n"
	
	keyBoardSettings()
	died()

func _on_wallNotifier_body_entered(body):
	if body.is_in_group("ship"):
		onWall()

func _on_wallNotifier_body_exited(body):
	if body.is_in_group("ship"):
		offWall()

func died():
	for i in get_tree().get_nodes_in_group("ship"):
		ship = i
	
	if ship.dead == true and dLock == false:
		dLock = true
		rockSpawners(false)
		animPlayer.play("deathMsg")
		env.adjustment_saturation = 0.01

func rockSpawners(spawn):
	for i in get_tree().get_nodes_in_group("spawner"):
		if spawn == true:
			i.doSpawnRocks = true
		else:
			i.doSpawnRocks = false

func onWall():
	var org = 1
	var des = 0.01
	mapTween.interpolate_method(env, "set_adjustment_saturation", org, des, 1, Tween.TRANS_EXPO)
	mapTween.interpolate_property(rWalls, "self_modulate", invi, notInvi, 1, Tween.TRANS_EXPO)
	
	
	mapTween.start()

func offWall():
	var org = 0.01
	var des = 1
	mapTween.interpolate_method(env, "set_adjustment_saturation", org, des, 1, Tween.TRANS_EXPO)
	mapTween.interpolate_property(rWalls, "self_modulate", notInvi, invi, 1, Tween.TRANS_EXPO)
	
	
	mapTween.start()

func _on_home_pressed():
	env.adjustment_saturation = 1
	var _changeScene = get_tree().change_scene("res://scn/menu/menu.tscn")

func _on_playAgain_pressed():
	var _changeScene = get_tree().change_scene("res://scn/game/menu.tscn")

extends Node2D

var blasterAmmo = preload("res://obj/ammo/blaster/blasterAmmo.tscn")
var homingAmmo = preload("res://obj/ammo/homingMissiles/homingAmmo.tscn")

onready var muzzle = $muzzle

func _process(_delta):
	shoot()

func shoot():
	
	if Input.is_action_just_pressed("fire") and get_parent().get_parent().ionBullets > 0:
		get_parent().get_parent().ionBullets -= 1
		var ammoInst = blasterAmmo.instance()
		get_parent().get_parent().call_deferred("add_child", ammoInst)
		get_parent().get_parent().animateBulletReduction()
		ammoInst.global_position = muzzle.global_position
		ammoInst.velocity = get_global_mouse_position() - get_parent().get_parent().global_position
		ammoInst.rotation_degrees = get_parent().get_parent().rotation_degrees
	
	elif Input.is_action_just_pressed("fireR") and get_parent().get_parent().sonicMissiles > 0:
		get_parent().get_parent().sonicMissiles -= 1
		var ammoInst = homingAmmo.instance()
		ammoInst.rotation_degrees = get_parent().get_parent().rotation_degrees
		get_parent().get_parent().call_deferred("add_child", ammoInst)
		get_parent().get_parent().animateMissileReduction()
		ammoInst.parent = "ship"
		ammoInst.global_position = muzzle.global_position

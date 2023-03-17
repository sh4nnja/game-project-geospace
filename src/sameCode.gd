extends Node

onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")

var damageSmall = 25
var damageBig = 15

var missileDamageSmall = 30
var missileDamageBig = 20

var sfx1
var sfx2
var sfx3

func _ready():
	sfx1 = load("res://assets/sfx1.wav")
	sfx2 = load("res://assets/sfx2.wav")
	sfx3 = load("res://assets/sfx3.wav")
	pass

func spawnNormalParticles(pos):
	var fxBoomInst = fxBoom.instance()
	get_node("/root/menu/game").call_deferred("add_child", fxBoomInst)
	fxBoomInst.position = pos

func spawnParticlesSmall(pos):
	var fxBoomInst = fxBoom.instance()
	get_node("/root/menu/game").call_deferred("add_child", fxBoomInst)
	fxBoomInst.position = pos
	fxBoomInst.amount = 150
	fxBoomInst.scale = Vector2(5, 5)
	fxBoomInst.scale_amount = 10

func spawnParticlesBig(pos):
	var fxBoomInst = fxBoom.instance()
	get_node("/root/menu/game").call_deferred("add_child", fxBoomInst)
	fxBoomInst.position = pos
	fxBoomInst.amount = 250
	fxBoomInst.scale = Vector2(10, 10)
	fxBoomInst.scale_amount = 20

func comments(type):
	var commentsCrit = ["Majestic", "Sheesh", "Fantastic", "Marvelous", "Angas", "Noice"]
	var commentsNorm = ["Great", "Cool", "Burn", "Hot", "Naks", "Yie"]
	var commentsMiss = ["Boo", "Missed", "Try Again", "Meh", "Bulok"]
	var commentsDamaged = ["Hit", "Ouch", "Watch Out", "Aguy", "Agoi"]
	var commentsGotMaterial = ["Material Gathered", "Got Material", "Material Retrieved"]
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	match type:
		0:
			return commentsNorm[rng.randi_range(0, commentsNorm.size() - 1)]
		1:
			return commentsCrit[rng.randi_range(0, commentsCrit.size() - 1)]
		2:
			return commentsMiss[rng.randi_range(0, commentsMiss.size() - 1)]
		3:
			return commentsDamaged[rng.randi_range(0, commentsDamaged.size() - 1)]
		4:
			return commentsGotMaterial[rng.randi_range(0, commentsGotMaterial.size() - 1)]

func reparent(child: Node, newParent: Node):
	var oldParent = child.get_parent()
	oldParent.remove_child(child)
	newParent.add_child(child)

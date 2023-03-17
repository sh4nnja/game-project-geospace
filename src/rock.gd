extends RigidBody2D

onready var rockTexture = $rockTexture

onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")
onready var materials = preload("res://obj/materials/materials.tscn")

var health = 100

var minColor = 0.1
var maxColor = 1

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	rockTexture.modulate = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	rotation_degrees = rng.randi_range(0, 360)

func _process(_delta):
	if health <= 0:
		set_physics_process(false)
		lib.spawnParticlesSmall(global_position)
		var matInst = materials.instance()
		get_node("/root/menu/game/stations").call_deferred("add_child", matInst)
		matInst.global_position = global_position
		queue_free()

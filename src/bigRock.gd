extends RigidBody2D

onready var rockTexture = $rockTexture
onready var collision = $shape

onready var trail = $trail

onready var miniRocks = preload("res://obj/rock/rock.tscn")
onready var miniRocks2 = preload("res://obj/rock/rock2.tscn")
onready var miniRocks3 = preload("res://obj/rock/rock3.tscn")
onready var miniRocks4 = preload("res://obj/rock/rock4.tscn")

onready var rareMaterials = preload("res://obj/materials/rareMaterials.tscn")

onready var spawn1 = $spawn1
onready var spawn2 = $spawn2
onready var spawn3 = $spawn3
onready var spawn4 = $spawn4
onready var spawn5 = $spawn5

var rocksPool = []
var rockPoolSize = 5

var health = 100

var minColor = 0.1
var maxColor = 1

func _ready():
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	rockTexture.modulate = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	rotation_degrees = rng.randi_range(0, 360)
	
	rockPooling()

func rockPooling():
	for _i in range(rockPoolSize):
		var miniRocksInst = checkShape()
		rocksPool.append(miniRocksInst)
	
func checkShape():
	var shape
	if is_in_group("circle"):
		shape = miniRocks3.instance()
	elif is_in_group("penta"):
		shape = miniRocks.instance()
	elif is_in_group("tri"):
		shape = miniRocks4.instance()
	elif is_in_group("hex"):
		shape = miniRocks2.instance()
	return shape

func _process(_delta):
	if health <= 0:
		set_physics_process(false)
		onDeathSpawnMiniRocks()

func onDeathSpawnMiniRocks():
	collision.disabled = true
	var spawnRegions = [spawn1, spawn2, spawn3, spawn4, spawn5]
	var index = 0
	for i in spawnRegions:
		var miniRocksInst = rocksPool[index]
		var rng = RandomNumberGenerator.new()
		get_node("/root/menu/game/rocks").call_deferred("add_child", miniRocksInst)
		miniRocksInst.position = i.global_position
		miniRocksInst.angular_velocity = rng.randf_range(0, 45)
		index += 1
	
	lib.spawnParticlesBig(global_position)
	queue_free()
	var rareMaterialsInst = rareMaterials.instance()
	get_node("/root/menu/game/rocks").call_deferred("add_child", rareMaterialsInst)
	rareMaterialsInst.global_position = global_position

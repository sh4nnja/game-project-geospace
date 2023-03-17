extends Node2D

export var spawnDirection: Vector2

onready var rock = preload("res://obj/rock/bigRock.tscn")
onready var rock2 = preload("res://obj/rock/bigRock2.tscn")
onready var rock3 = preload("res://obj/rock/bigRock3.tscn")
onready var rock4 = preload("res://obj/rock/bigRock4.tscn")

onready var star1 = preload("res://obj/star/star1.tscn")

onready var spawnTimer = $timer

onready var spawn1 = $"1"
onready var spawn2 = $"2"
onready var spawn3 = $"3"
onready var spawn4 = $"4"
onready var spawn5 = $"5"

var poolSize = 10
var rockPool = []

var spawnTime = 15

var doSpawnRocks = false

var index = 0

func _ready():
	addSpawns()

func addSpawns():
	spawnTimer.wait_time = spawnTime
	
	var rng = RandomNumberGenerator.new()
	for _i in range(poolSize):
		rng.randomize()
		var itemToAdd = rng.randi_range(0, 10)
		match itemToAdd:
			0, 2, 7:
				rockPool.append(rock.instance())
			1, 3, 9:
				rockPool.append(rock2.instance())
			2, 5, 8:
				rockPool.append(rock3.instance())
			3, 6, 10: 
				rockPool.append(rock4.instance())
			4:
				rockPool.append(star1.instance())

func spawnRocks():
	if get_tree().get_nodes_in_group("big").size() < 30 and doSpawnRocks == true:
		var spawnPoints = [spawn1, spawn2, spawn3, spawn4, spawn5]
		for i in spawnPoints:
			var rng = RandomNumberGenerator.new()
			var rockInst = rockPool[index]
			rng.randomize()
		
			get_node("/root/menu/game/rocks").call_deferred("add_child", rockInst)
			
			rockInst.position = i.global_position
			rockInst.linear_velocity = spawnDirection
			rockInst.angular_velocity = rng.randf_range(0, 50)
			rockPool.remove(index)
			index += 1
		
		index = 0
		addSpawns()

func _on_timer_timeout():
	spawnRocks()

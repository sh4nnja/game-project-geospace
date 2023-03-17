extends RigidBody2D

onready var bulletScene = preload("res://obj/ammo/starBullet/starBullet.tscn")
onready var homingBullet = preload("res://obj/ammo/homingMissiles/homingAmmo.tscn")
onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")
onready var materials = preload("res://obj/materials/materials.tscn")

onready var collision = $shape
onready var starTexture = $starTexture
onready var shootTimer = $shootTimer
onready var rotater = $rotator
onready var reloadTimer = $reload

onready var ctm = $combatTextManager

var canShoot = false
var bigBody

var health = 100
var bullets = 25

var rotateSpeed = 100
var shootTimer_waitTime = 1
var spawnPoint_count = 5
var radius = 200

var minColor = 0.35
var maxColor = 1

var check = false

func _ready():
	randomPattern()
	randomDesign()
	var step = 2 * PI / spawnPoint_count
	for i in range(spawnPoint_count):
		var spawnPoint = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawnPoint.position = pos
		spawnPoint.rotation = pos.angle()
		rotater.add_child(spawnPoint)
	shootTimer.wait_time = shootTimer_waitTime
	shootTimer.start()

func _physics_process(delta):
	var newRotation = rotater.rotation_degrees + rotateSpeed * delta
	rotater.rotation_degrees = fmod(newRotation, 360)
	
	if health <= 0:
		onDeathSpawnMiniRocks()

func randomPattern():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var modeOfFiring = rng.randi_range(1, 3)
	match modeOfFiring:
		1:
			rotateSpeed = 160
			shootTimer_waitTime = 0.1
			spawnPoint_count = 1
		2:
			rotateSpeed = 50
			shootTimer_waitTime = 0.2
			spawnPoint_count = 2
		3:
			rotateSpeed = 360
			shootTimer_waitTime = 0.1
			spawnPoint_count = 1

func _on_shootTimer_timeout():
	if bullets <= 0 and check == false:
		check = true
		reloadTimer.start()

	for s in rotater.get_children():
		if canShoot == true and bullets > 0:
			var bullet = bulletScene.instance()
			get_node("/root/menu/game").add_child(bullet)
			bullet.global_position = s.global_position
			bullet.rotation = s.global_rotation
			bullets -= 1

func randomDesign():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	starTexture.self_modulate = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	rotation_degrees = rng.randi_range(0, 360)

func onDeathSpawnMiniRocks():
	lib.spawnParticlesBig(global_position)
	for _i in range(3):
		var matInst = materials.instance()
		get_node("/root/menu/game/stations").call_deferred("add_child", matInst)
		matInst.global_position = global_position
	queue_free()

func _on_detection_body_entered(body):
	if body.is_in_group("ship"):
		canShoot = true

func _on_detection_body_exited(body):
	if body.is_in_group("ship"):
		canShoot = false

func _on_reload_timeout():
	check = false
	randomPattern()
	bullets = 50

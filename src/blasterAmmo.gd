extends KinematicBody2D

onready var timer = $selfDestruct
onready var trails = $trails
onready var fxPoint = $fxPoint

onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")

var trailLength = 10
var trailPoint = Vector2()

var velocity = Vector2(0, 0)
var speed = 1000
var push = 600

var minColor = 0.01
var maxColor = 1

func _ready():
	set_as_toplevel(true)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	trailLength = rng.randi_range(5, 15)
	rng.randomize()
	trails.default_color = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	speed = rng.randi_range(2000, 3000)
	
	rotation += rng.randf_range(-0.2, 0.2)

func _physics_process(_delta):
	velocity = Vector2()
	velocity += transform.x * speed
	var _velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("body"):
			collision.collider.apply_central_impulse(-collision.normal * push)
			queue_free()
	
	addFxBoomOnHit()
	trailAnimation()

func addFxBoomOnHit():
	if fxPoint.is_colliding():
		var fxBoomInst = fxBoom.instance()
		get_parent().get_parent().get_parent().add_child(fxBoomInst)
		fxBoomInst.position = fxPoint.get_collision_point()
		if fxPoint.get_collider().is_in_group("small"):
			fxPoint.get_collider().health -= lib.damageSmall
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(0), 0)
			sfx.playerSfx(lib.sfx2, 1, 0.1)
		elif fxPoint.get_collider().is_in_group("big"):
			fxPoint.get_collider().health -= lib.damageBig
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(1), 0)
			sfx.playerSfx(lib.sfx2, 1, 0.1)
		elif fxPoint.get_collider().is_in_group("enemy"):
			fxPoint.get_collider().health -= lib.damageBig
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(1), 0)
			sfx.playerSfx(lib.sfx2, 1, 0.1)
		
		queue_free()

func trailAnimation():
	trails.global_position = Vector2(0,0)
	trails.global_rotation = 0
	trailPoint = global_position
	
	trails.add_point(trailPoint)
	
	while trails.get_point_count() > trailLength:
		trails.remove_point(0)

func _on_selfDestruct_timeout():
	lib.spawnNormalParticles(global_position)
	queue_free()




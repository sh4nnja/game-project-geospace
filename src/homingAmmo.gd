extends KinematicBody2D

onready var timer = $selfDestruct
onready var trails = $trails
onready var fxPoint = $fxPoint

onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")

onready var detection = $detection/shape

var mousePosition

var trailLength = 15
var trailPoint = Vector2()

var velocity = Vector2(0, 0)
var accel = Vector2()
var speed = 890
var push = 600

var steerForce = 850
var parent
var target
var find

var minColor = 0.01
var maxColor = 1

func _ready():
	set_as_toplevel(true)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	trailLength = rng.randi_range(25, 35)
	rng.randomize()
	trails.default_color = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	speed = rng.randi_range(2000, 3000)

	velocity = transform.x * speed

func seekTarget():
	var steer = Vector2()
	if target:
		var desired = (target - position).normalized() * speed
		steer = (desired - velocity).normalized() * steerForce
	return steer

func _physics_process(delta):
	accel += seekTarget()
	velocity += accel * delta
	velocity = velocity.clamped(speed)
	var _velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false) * delta
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var fxBoomInst = fxBoom.instance()
		get_parent().get_parent().get_parent().add_child(fxBoomInst)
		fxBoomInst.position = global_position
		if collision.collider.is_in_group("body"):
			collision.collider.apply_central_impulse(-collision.normal * push)
			collision.collider.get_node("combatTextManager").showValue(lib.comments(2), 2)
			sfx.playerSfx(lib.sfx1, 1, 0.1)
		
		elif collision.collider.is_in_group("ship"):
			collision.collider.get_node("combatTextManager").showValue(lib.comments(3), 0)
			collision.collider.startShake(0.75)
			
		
			
		queue_free()
	
	addFxBoomOnHit()
	trailAnimation()

func addFxBoomOnHit():
	if fxPoint.is_colliding():
		lib.spawnNormalParticles(fxPoint.get_collision_point())
		if fxPoint.get_collider().is_in_group("small"):
			fxPoint.get_collider().health -= 60
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(1), 1)
			sfx.playerSfx(lib.sfx3, 1, 0.6)
		elif fxPoint.get_collider().is_in_group("big"):
			fxPoint.get_collider().health -= 25
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(1), 1)
			sfx.playerSfx(lib.sfx3, 1, 0.6)
		elif fxPoint.get_collider().is_in_group("enemy"):
			fxPoint.get_collider().health -= 35
			fxPoint.get_collider().get_node("combatTextManager").showValue(lib.comments(1), 1)
			sfx.playerSfx(lib.sfx3, 1, 0.6)
		
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

func _on_detection_body_entered(body):
	if body.is_in_group("small") or body.is_in_group("big") or body.is_in_group("enemy") and parent == "ship":
		target = body.global_position


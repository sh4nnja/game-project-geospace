extends KinematicBody2D

onready var materialTexture = $texture
onready var tween = $tween

var velocity = Vector2(0, 0)
var accel = Vector2()

var target
var pos
var track = false

var speed = 850
var steerForce = 850

var minColor = 0.35
var maxColor = 1

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	materialTexture.self_modulate = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	
	rotation_degrees = rng.randi_range(0, 360)
	velocity = transform.x * speed
	


func _physics_process(delta):
	for i in get_tree().get_nodes_in_group("ship"):
		target = i.global_position

	accel += goToPlayer()
	velocity += accel * delta
	velocity = velocity.clamped(speed)
	var _velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false) * delta

func goToPlayer():
	var steer = Vector2()
	if target:
		var desired = (target - position).normalized() * speed
		steer = (desired - velocity).normalized() * steerForce
	return steer




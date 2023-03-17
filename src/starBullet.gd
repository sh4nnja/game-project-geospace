extends Node2D

onready var fxBoom = preload("res://obj/fx/boom/boomFX.tscn")
onready var starTexture = $star

var speed = 600

var minColor = 0.35
var maxColor = 1

func _ready():
	randomDesign()
	set_as_toplevel(true)

func _physics_process(delta):
	global_position += transform.x * delta * speed

func _on_selfDestruct_timeout():
	var fxBoomInst = fxBoom.instance()
	get_parent().get_parent().get_parent().add_child(fxBoomInst)
	fxBoomInst.position = global_position
	queue_free()

func _on_area_body_entered(body):
	if body.is_in_group("ship") or body.is_in_group("body"):
		if body.is_in_group("ship"):
			body.get_node("combatTextManager").showValue(lib.comments(2), 0)
			body.startShake(0.75)
			body.health -= 25
			sfx.playerSfx(lib.sfx1, 1, 0.6)
			
		if body.is_in_group("small"):
			body.health -= 25
		elif body.is_in_group("big"):
			body.health -= 10
		
		var fxBoomInst = fxBoom.instance()
		get_parent().get_parent().get_parent().add_child(fxBoomInst)
		fxBoomInst.position = global_position
		queue_free()
		
func randomDesign():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	starTexture.self_modulate = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	rng.randomize()
	rotation_degrees = rng.randi_range(0, 360)

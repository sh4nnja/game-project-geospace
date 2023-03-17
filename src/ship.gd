extends KinematicBody2D

onready var texture = $texture
onready var trails = $trails
onready var camera = $camera
onready var noise = OpenSimplexNoise.new()
onready var collisionS = $shape

onready var ui = $UILayer/ui/bulletStats

onready var ionStats = $UILayer/ui/bulletStats/ionBlasterAmmo/ionStats
onready var sonicStats = $UILayer/ui/bulletStats/sonicMissileAmmo/sonicStats
onready var matStats = $UILayer/ui/bulletStats/materialsIcon/matStats

onready var ionLabel = $UILayer/ui/bulletStats/ionBlasterAmmo/ionLabel
onready var sonicLabel = $UILayer/ui/bulletStats/sonicMissileAmmo/sonicLabel
onready var matLabel = $UILayer/ui/bulletStats/materialsIcon/matLabel
onready var rareMatStats = $UILayer/ui/bulletStats/materialsIcon/rareMatStats

onready var ionIcon = $UILayer/ui/bulletStats/ionBlasterAmmo
onready var sonicIcon = $UILayer/ui/bulletStats/sonicMissileAmmo
onready var matIcon = $UILayer/ui/bulletStats/materialsIcon

onready var bulletValueTween = $UILayer/ui/bulletStats/tweenBulletStats
onready var missileValueTween = $UILayer/ui/bulletStats/tweenMissileStats

onready var ionTween = $UILayer/ui/bulletStats/ionBlasterAmmo/ionTween
onready var sonicTween = $UILayer/ui/bulletStats/sonicMissileAmmo/sonicTween
onready var matTween = $UILayer/ui/bulletStats/materialsIcon/matTween

onready var ionTimer = $ionTimer
onready var sonicTimer = $sonicTimer

onready var radialMenu = $holder/radialMenu
onready var radialAnim = $holder/radialMenu/animation

var globalDelta

var health = 100
var dead = false

var boosterColor = Color(0, 1, 1)
var shipColor = Color(0, 0, 0)

var velocity
var offset = 10

var speed = 750
var push = 500

var trailLength = 25
var trailPoint = Vector2()

var trauma = 0.0
var traumaP = 3
var decay = 0.8

var maxOffset = Vector2(100, 75)
var maxRoll = 0.1

var noiseY = 0

var iBMax: int = 100
var ionBullets: int = iBMax

var sMMax: int = 80
var sonicMissiles: int = sMMax

var materialsGathered = 5
var rareMaterialsGathered = 5

var lockBulletLoading = false
var lockMissileLoading = false

var rOpen = false

func _ready():
	radialMenu.set_as_toplevel(true)
	self_modulate = shipColor
	trails.default_color = boosterColor
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
func _physics_process(delta):
	globalDelta = delta
	movement()
	trailAnimation()
	
	initShake()
	showStatsOnScreen()
	revertBackToMaxValue()
	updateColorStats()
	radialMenuPosition()
	checkIfDead()

func _input(_event):
	zoomCamera()
	openRadialMenu()
	offUI()

func movement():
	velocity = Vector2()
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("fw"):
		velocity += transform.x * speed
	if Input.is_action_pressed("bk"):
		velocity -= transform.x * speed
		
	if position.distance_to(get_global_mouse_position()) > offset:
		var _velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("body"):
			get_node("combatTextManager").showValue(lib.comments(3), 0)
			sfx.playerSfx(lib.sfx1, 1, 0.6)
			health -= 5
			startShake(0.55)
			collision.collider.apply_central_impulse(-collision.normal * push)

func trailAnimation():
	trails.global_position = Vector2(0,0)
	trails.global_rotation = 0
	trailPoint = global_position
	
	trails.add_point(trailPoint)
	
	while trails.get_point_count() > trailLength:
		trails.remove_point(0)

func initShake():
	if trauma:
		trauma = max(trauma - decay * globalDelta, 0)
		shake()

func shake():
	var amount = pow(trauma, traumaP)
	noiseY += 1
	camera.rotation = maxRoll * amount * noise.get_noise_2d(noise.seed, noiseY)
	camera.offset.x = maxOffset.x * amount * noise.get_noise_2d(noise.seed * 2, noiseY)
	camera.offset.y = maxOffset.y * amount * noise.get_noise_2d(noise.seed * 3, noiseY)

func startShake(amount):
	trauma = min(trauma + amount, 1.0)

func showStatsOnScreen():
	ionStats.text = str(ionBullets)
	sonicStats.text = str(sonicMissiles)
	matStats.text = str(materialsGathered)
	rareMatStats.text = str(rareMaterialsGathered)

func zoomCamera():
	if Input.is_action_just_released("zUP") and camera.zoom < Vector2(15, 15):
		camera.zoom += Vector2(0.6, 0.6)
	elif Input.is_action_just_released("zDOWN") and camera.zoom > Vector2(2.5, 2.5):
		camera.zoom -= Vector2(0.6, 0.6)
	
func revertBackToMaxValue():
	if Input.is_action_just_released("fire"):
		ionTimer.start()
	
	if Input.is_action_just_released("fireR"):
		sonicTimer.start()
	
	if ionBullets < iBMax and lockBulletLoading == false:
		yield(ionTimer, "timeout")
		bulletValueTween.interpolate_property(self, "ionBullets", ionBullets, iBMax, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		lockBulletLoading = true
		bulletValueTween.start()
	
	if sonicMissiles < sMMax and lockMissileLoading == false:
		yield(sonicTimer, "timeout")
		missileValueTween.interpolate_property(self, "sonicMissiles", sonicMissiles, sMMax, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		lockMissileLoading = true
		missileValueTween.start()

func _on_tweenBulletStats_tween_all_completed():
	lockBulletLoading = false

func _on_tweenMissileStats_tween_all_completed():
	lockMissileLoading = false

func animateBulletReduction():
	ionTween.interpolate_property(ionStats, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	ionTween.start()

func animateMissileReduction():
	sonicTween.interpolate_property(sonicStats, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	sonicTween.start()

func animateMaterialAddition(type):
	if type == 1:
		matTween.interpolate_property(matStats, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
		matTween.interpolate_property(matStats, "self_modulate", Color(0, 1, 0), Color(1, 1, 1), 0.4, Tween.TRANS_BACK)
		matTween.interpolate_property(matLabel, "self_modulate", Color(0, 1, 0), Color(1, 1, 1), 0.4, Tween.TRANS_BACK)
		matTween.interpolate_property(matIcon, "self_modulate", Color(0, 1, 0, 0.39), Color(1, 1, 1, 0.39), 0.4, Tween.TRANS_BACK)

	elif type == 2:
		matTween.interpolate_property(rareMatStats, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
		matTween.interpolate_property(rareMatStats, "self_modulate", Color(0.5, 0, 1), Color(1, 1, 1), 0.4, Tween.TRANS_BACK)
		matTween.interpolate_property(matLabel, "self_modulate", Color(0.5, 0, 1), Color(1, 1, 1), 0.4, Tween.TRANS_BACK)
		matTween.interpolate_property(matIcon, "self_modulate", Color(0.5, 0, 1, 0.39), Color(1, 1, 1, 0.39), 0.4, Tween.TRANS_BACK)

	matTween.start()

func updateColorStats():
	if ionBullets > 50:
		ionStats.self_modulate = Color(1, 1, 1)
		ionLabel.self_modulate = Color(1, 1, 1)
		ionIcon.self_modulate = Color(1, 1, 1, 0.39)
	elif ionBullets < 50:
		ionStats.self_modulate = Color(1, 0.5, 0)
		ionLabel.self_modulate = Color(1, 0.5, 0)
		ionIcon.self_modulate = Color(1, 0.5, 0, 0.39)
	if ionBullets < 25:
		ionStats.self_modulate = Color(1, 0, 0)
		ionLabel.self_modulate = Color(1, 0, 0)
		ionIcon.self_modulate = Color(1, 0, 0, 0.39)
	
	if sonicMissiles > 40:
		sonicStats.self_modulate = Color(1, 1, 1)
		sonicLabel.self_modulate = Color(1, 1, 1)
		sonicIcon.self_modulate = Color(1, 1, 1, 0.39)
	elif sonicMissiles < 40:
		sonicStats.self_modulate = Color(1, 0.5, 0)
		sonicLabel.self_modulate = Color(1, 0.5, 0)
		sonicIcon.self_modulate = Color(1, 0.5, 0, 0.39)
	if sonicMissiles < 20:
		sonicStats.self_modulate = Color(1, 0, 0)
		sonicLabel.self_modulate = Color(1, 0, 0)
		sonicIcon.self_modulate = Color(1, 0, 0, 0.39)

func _on_detection_body_entered(body):
	if body.is_in_group("material"):
		get_node("combatTextManager").showValue(lib.comments(4), 3)
		animateMaterialAddition(1)
		materialsGathered += 1
		var trail = body.get_node("trail")
		lib.reparent(trail, get_node("/root/menu/game/stations"))
		body.queue_free()
		yield(get_tree().create_timer(1), "timeout")
		trail.queue_free()
		trail = null
		
	elif body.is_in_group("rareMaterial"):
		get_node("combatTextManager").showValue(lib.comments(4), 4)
		animateMaterialAddition(2)
		rareMaterialsGathered += 1
		var trail = body.get_node("trail")
		lib.reparent(trail, get_node("/root/menu/game/stations"))
		body.queue_free()
		yield(get_tree().create_timer(1), "timeout")
		trail.queue_free()
		trail = null

func openRadialMenu():
	if Input.is_action_just_pressed("inv") and rOpen == false:
		rOpen = true
		radialAnim.play("radial")
	elif Input.is_action_just_pressed("inv") and rOpen == true:
		rOpen = false
		radialAnim.play_backwards("radial")

func radialMenuPosition():
	radialMenu.rect_global_position = global_position

func checkIfDead():
	if health <= 0:
		died(1)
		dead = true

func died(type):
	if type == 1:
		pass

	if type == 2:
		pass
	
	hide()
	set_process(false)
	ui.modulate = Color(1, 1, 1, 0)
	
	ionBullets = 0
	sonicMissiles = 0
		
	collisionS.disabled = true

func offUI():
	if Input.is_action_just_pressed("offUI") and ui.visible == true:
		ui.hide()
	elif Input.is_action_just_pressed("offUI") and ui.visible == false:
		ui.show()

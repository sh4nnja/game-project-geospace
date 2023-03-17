extends RigidBody2D

onready var stats = $stats

onready var neededMat = $stats/materialNeed/need
onready var neededRareMat = $stats/rareMaterialNeed/need

onready var matTween = $stats/tween

onready var depoText = $UILayer/ui/deposit

onready var animPlayer = $player

onready var texture = $sprite
onready var trail = $trail

var texture2 = preload("res://assets/cosmicTeleporterModuleP2.svg")
var texture3 = preload("res://assets/cosmicTeleporterModuleP3.svg")

var canDeposit = false

var player

var phase = 0
var randomItemPool = [Vector2(5, 15), Vector2(15, 25), Vector2(25, 35)]

var needMaterials = Vector2(0,0)

func _ready():
	stats.set_as_toplevel(true)
	randomNeeds(randomItemPool[phase])

func _process(_delta):
	followCTM()
	showStats()
	
	checkForMaterialInput()
	checkStats()
	
func followCTM():
	stats.rect_global_position = self.global_position - Vector2(530, 350)

func showStats():
	neededMat.text = str(needMaterials.x)
	neededRareMat.text = str(needMaterials.y)

func randomNeeds(values: Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	needMaterials.x = rng.randi_range(values.x, values.y)
	needMaterials.y = rng.randi_range(values.x, values.y)

func _on_detection_body_entered(body):
	if body.is_in_group("ship"):
		animPlayer.play("stats")
		canDeposit = true
		player = body

func _on_detection_body_exited(body):
	if body.is_in_group("ship"):
		animPlayer.play_backwards("stats")
		canDeposit = false
		body = null

func checkStats():
	if needMaterials.x == 0 and needMaterials.y == 0:
		randomNeeds(randomItemPool[phase])
		phase += 1
		
	if phase == 1:
		texture.texture = texture2
		trail.lifetime = 5
		trail.linear_accel = 15
		trail.scale = Vector2(10, 10)
	elif phase == 2:
		texture.texture = texture3
		trail.scale = Vector2(15, 15)
		
	if phase > 2:
		for i in get_tree().get_nodes_in_group("spawners"):
			i.doSpawnRocks = false
		set_process(false)
		get_node("/root/menu").env.adjustment_saturation = 0.01
		get_node("/root/menu/animPlayer").play("victoryMsg")
		get_node("/root/menu/game/shipHere/ship").died(2)
		
func checkForMaterialInput():
	if Input.is_action_just_pressed("teleporter") and canDeposit == true:
		if player.materialsGathered > 0:
			var deductingVal = player.materialsGathered
			var compare = needMaterials.x - deductingVal
			if compare > 0:
				needMaterials.x -= deductingVal
				yield(get_tree().create_timer(0.5), "timeout")
				player.materialsGathered -= deductingVal
			else:
				var left = needMaterials.x
				needMaterials.x -= left
				yield(get_tree().create_timer(0.5), "timeout")
				player.materialsGathered -= left
			
			tweenStats(1)
			player.animateMaterialAddition(1)

		if player.rareMaterialsGathered > 0:
			var deductingVal = player.rareMaterialsGathered
			var compare = needMaterials.y - deductingVal
			if compare > 0:
				needMaterials.y -= deductingVal
				yield(get_tree().create_timer(0.5), "timeout")
				player.rareMaterialsGathered -= deductingVal
			else:
				var left = needMaterials.y
				needMaterials.y -= left
				yield(get_tree().create_timer(0.5), "timeout")
				player.rareMaterialsGathered -= left
			
			tweenStats(2)
			player.animateMaterialAddition(2)

func tweenStats(type):
	if type == 1:
		matTween.interpolate_property(neededMat, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	elif type == 2:
		matTween.interpolate_property(neededRareMat, "rect_scale", Vector2(1.25, 1.25), Vector2(1, 1), 0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	matTween.start()

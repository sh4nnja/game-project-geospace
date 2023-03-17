extends Node2D

onready var label = $combatText
onready var tween = $combatText/tween

func _ready():
	set_as_toplevel(true)

func showValue(value, duration, crit):
	label.text = value
	label.rect_pivot_offset = label.rect_size / 2
	match crit:
		0: #NORM
			get_tree().get_root().get_node("menu/game/shipHere/ship").startShake(0.25)
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			label.modulate = Color(rng.randf_range(0,1), rng.randf_range(0,1), rng.randf_range(0,1))
			tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			
		1: #CRITICAL
			get_tree().get_root().get_node("menu/game/shipHere/ship").startShake(0.5)
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			label.modulate = Color(rng.randf_range(0,1), rng.randf_range(0,1), rng.randf_range(0,1))
			tween.interpolate_property(label, "rect_scale", label.rect_scale * 2, label.rect_scale,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
		
		2: #DULL
			tween.interpolate_property(label, "rect_scale", label.rect_scale / 2, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
		
		3: #POSITIVE TEXTS (GREEN)
			tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.self_modulate = Color(0, 1, 0)
		
		4: #POSITIVE TEXTS (VIOLET)
			tween.interpolate_property(label, "rect_scale", label.rect_scale, label.rect_scale / 2,
				0.4, Tween.TRANS_BACK, Tween.EASE_IN)
			label.self_modulate = Color(0.5, 0, 1)
	
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_all_completed")
	set_physics_process(false)
	set_process(false)
	hide()

func _on_timer_timeout():
	queue_free()

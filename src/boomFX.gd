extends CPUParticles2D

var minColor = 0.1
var maxColor = 1

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	color = Color(rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor), rng.randf_range(minColor, maxColor))
	emitting = true

func _on_Timer_timeout():
	queue_free()

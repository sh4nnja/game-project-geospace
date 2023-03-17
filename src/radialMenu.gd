extends Control

onready var option1 = $anchor/radialHolder/anchor/option1
onready var option2 = $anchor/radialHolder/anchor2/option2
onready var option3 = $anchor/radialHolder/anchor3/option3
onready var option4 = $anchor/radialHolder/anchor4/option4

onready var tween = $anchor/radialHolder/tween



func _on_option1_mouse_entered():
	tweenOpenNode(option1)

func _on_option1_mouse_exited():
	tweenCloseNode(option1)

func _on_option2_mouse_entered():
	tweenOpenNode(option2)

func _on_option2_mouse_exited():
	tweenCloseNode(option2)

func _on_option3_mouse_entered():
	tweenOpenNode(option3)

func _on_option3_mouse_exited():
	tweenCloseNode(option3)

func _on_option4_mouse_entered():
	tweenOpenNode(option4)

func _on_option4_mouse_exited():
	tweenCloseNode(option4)


func tweenOpenNode(node: Node):
	var org = Vector2(1, 1)
	var des = Vector2(1.5, 1.5)
	tween.interpolate_property(node, "rect_scale", org, des, 0.25, Tween.TRANS_EXPO)
	tween.start()

func tweenCloseNode(node: Node):
	var org = node.rect_scale
	var des = Vector2(1, 1)
	tween.interpolate_property(node, "rect_scale", org, des, 0.25, Tween.TRANS_EXPO)
	tween.start()

func _on_option1_pressed():
	print("Lmfao")

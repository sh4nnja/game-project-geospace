extends Node

onready var player1 = $player1
onready var player2 = $player2

func playerSfx(sfx, player, db):
	if player == 1:
		player1.stream_paused = false
		player1.stream = sfx
		player1.volume_db = db 
		player1.play()
	elif player == 2:
		player2.stream_paused = false
		player2.stream = sfx
		player2.volume_db = db 
		player2.play()

func _on_player1_finished():
	player1.stream_paused = true

func _on_player2_finished():
	player2.stream_paused = true

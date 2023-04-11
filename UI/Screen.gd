extends CanvasLayer

# load sound effects
onready var dead_sound = preload("res://Sounds/lose music 3-0.wav")

# variables
var level
var score

signal can_game_start

func _ready():
	# When first load the game
	if Global.game_start:
		# no result
		$result_box.hide()
		$level.text ="";
		$score.text ="";
		# hide info about when game over
		$Background/MarginContainer/Rows/game_over.hide()
		# change text to start game
		$Background/MarginContainer/Rows/Control/VBoxContainer/Restart.text = "START GAME"
	else:
		# show highest scores and levels
		$result_box.show()
		$level.text ="Highest Levels: " + str(Global.level)
		$score.text = "Highest Scores: " + str(Global.score)
		# play sound
		$dead_sound.stream = dead_sound
		$dead_sound.play()
		# change text to restart game
		$Background/MarginContainer/Rows/Control/VBoxContainer/Restart.text = "RESTART GAME"

func _on_Restart_pressed()->void:	
	# When first load the game
	if Global.game_start:
		# set can_start to true
		emit_signal("can_game_start")
		queue_free()
	else:
		# restart the game
		get_tree().paused = false
		get_tree().change_scene("res://main.tscn")
		
# when pressed quit the game
func _on_Quit_pressed()->void:
	get_tree().quit()
	
# show instruction on how to play
func _on_Help_pressed():
	# hide menu show instruction
	$Intro.show()
	$Background.hide()

func _on_Back_pressed():
	# show menu, hide insctudtion
	$Intro.hide()
	$Background.show()

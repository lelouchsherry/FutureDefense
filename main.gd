extends Node

# load instance
onready var screen = preload("res://UI/Screen.tscn")
onready var mob = preload("res://Invaders/invander.tscn")
onready var projectile = preload("res://Invaders/projectile.tscn")
onready var tower = preload("res://Invaders/tower.tscn")

# load sound effects
onready var fire_sound = preload("res://Sounds/FireLaserBolt.wav")
onready var click_sound = preload("res://Sounds/flopp med underleppa (flanger9).wav")
onready var place_sound = preload("res://Sounds/hjm-tesla_sound_shot.wav")
onready var dead_sound = preload("res://Sounds/lose sound 1-2.wav")
	
var mobs_remaining = 0
var lives = 3
var gold = 1

var can_place_tower = false
var invalid_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	# start game when click start game
	if Global.can_start:
		# initially set up the game
		init_game()
	else:
		$invander_timer.stop()
		# load the main screen
		# make an instance of the screen
		var screen_instance = null
		screen_instance = screen.instance()
		screen_instance.connect("can_game_start", self, "can_game_start")
		$container.add_child(screen_instance)
		
func can_game_start():
	Global.can_start = true
	init_game()
	
func init_game():	
	# initialize variables
	mobs_remaining = 3
	Global.score = 0
	Global.level = 0

	# start the timer
	$invander_timer.start(1)
	# towers cannot be placed on these tiles
	invalid_tiles = $nav/tilemap_nav.get_used_cells()
	
	# update score and other utilities
	$user_interface/points.text = "Scores: " + str(Global.score)
	$user_interface/hbox1/gold.text = str(gold)
	$user_interface/level.text = "Level: " + str(Global.level)
		
func _process(delta):
	# show the timer
	$user_interface/next_wave_time.text = str(int($invander_timer.time_left))

# mouse event handler
func _unhandled_input(event):
	if event is InputEventMouseMotion and can_place_tower:
		$tower_placement.clear()
		
		# get the tile location of the mouse cursor
		var tile = $tower_placement.world_to_map(event.position)
		
		if not tile in invalid_tiles:
			# color green / valid tile
			$tower_placement.set_cell(tile.x, tile.y, 0)
		else:
			# color red / invalid tile
			$tower_placement.set_cell(tile.x, tile.y, 1)
			
	elif event is InputEventMouseButton and can_place_tower and event.pressed:
		# get the tile location of the mouse cursor
		var tile = $tower_placement.world_to_map(event.position)
		
		if not tile in invalid_tiles:
			can_place_tower = false
			$tower_placement.clear()
			
			# the tile is now invalid for other towers
			invalid_tiles.append(tile)
			
			# place the tower
			var tower_instance = tower.instance()
			tower_instance.connect("shoot_projectile", self, "shoot_projectile")
			tower_instance.position = tile * Vector2(64, 64)
			$container.add_child(tower_instance)
			play_effect($place_sound, place_sound);
						
			gold -= Global.level
			$user_interface/hbox1/gold.text = str(gold)
			disableTower()
				
func _on_invander_timer_timeout():	
	if mobs_remaining >= (3 * Global.level):
		Global.level += 1
		# update level and cost
		$user_interface/level.text = "Level: " + str(Global.level)
		$user_interface/hbox2/cost.text = str(Global.level)
	
	# no more gold to buy disable the tower button
	disableTower()
	
	# make an instance of the mob
	var mob_instance = null
	mob_instance = mob.instance()
	mob_instance.connect("mob_defeated", self, "mob_defeated")
	mob_instance.connect("lose_a_life", self, "lose_a_life")
	
	# set the starting position and the destination
	mob_instance.position = $start_position.position
	mob_instance.destination = $end_position.position
	
	# set the path it is going to follow
	var path = $nav.get_simple_path($start_position.position, $end_position.position)
	mob_instance.set_path(path)
	
	# add the mob to the entities container
	$container.add_child(mob_instance)
				
	# disable "next wave" button
	$user_interface/start_next_wave.disabled = true
	mobs_remaining -= 1
	
	if mobs_remaining > 0:
		$invander_timer.start(1)
	else:
		# reset the timer for the next wave
		$invander_timer.start((60/Global.level))
		# reset the mobs_remaining counter
		mobs_remaining = (3 * (Global.level+1))
		# enable "next wave" button
		$user_interface/start_next_wave.disabled = false
	
func shoot_projectile(origin, target):
	var projectile_instance = projectile.instance()
	projectile_instance.origin_pos = origin
	projectile_instance.target_pos = target
	$container.add_child(projectile_instance)
	play_effect($fire_sound, fire_sound)
	
func mob_defeated():
	Global.score += 1
	$user_interface/points.text = "Scores: " + str(Global.score)
	
	gold += 1
	$user_interface/hbox1/gold.text = str(gold)
	
	if gold >= Global.level:
		# enable "tower" button
		$user_interface/spaceship.disabled = false

func lose_a_life():
	# loose 1 life
	lives -= 1
	# play dead sound effect
	play_effect($dead_sound, dead_sound);
	# show and hide heart
	if(lives == 2):
		# hide heart3 and show heart4
		$user_interface/title/hbox1/heart3.hide()
		$user_interface/title/hbox1/heart4.show()
	elif(lives == 1):
		# hide heart2 and show heart5
		$user_interface/title/hbox1/heart2.hide()
		$user_interface/title/hbox1/heart5.show()
	else: # if no more lives end the game
		# hide heart1 and show heart6
		$user_interface/title/hbox1/heart1.hide()
		$user_interface/title/hbox1/heart6.show()
		# stop the game
		$invander_timer.stop()
		Global.game_start = false;
		get_tree().paused = false;
		# show game over scene
		get_tree().change_scene("res://UI/Screen.tscn")
		
func _on_start_next_wave_pressed():
	_on_invander_timer_timeout()
	play_effect($click_sound, click_sound);

func _on_spaceship_pressed():
		$tower_placement.clear()
		can_place_tower = !can_place_tower
		play_effect($click_sound, click_sound);
		
# Helper function for play sounds effect
func play_effect(param, clip):
	param.stream = clip
	param.play()

# Helper function disable place tower
func disableTower():
	# no more gold to buy disable the tower button
	if gold < Global.level:
		# disable "tower" button
		$user_interface/spaceship.disabled = true

extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)

func _input(event):
	# when escape button pressed and not at main menu
	if event.is_action_pressed("ui_cancel") and Global.can_start: 
		set_visible(!get_tree().paused) # if not pause then hid
		get_tree().paused = !get_tree().paused #toggle pause status

# when press continue game start
func _on_Continue_pressed():
	get_tree().paused = false
	set_visible(false)

# quit the game
func _on_Quit_pressed():
	get_tree().quit()
	
func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible

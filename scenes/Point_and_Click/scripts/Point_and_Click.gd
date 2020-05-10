extends Node

# This is a point and click game, sounds fair to have all the time
# in mind where is mouse, which object is under it, which action is currently
# selected, and  who's inventory is on screen (for multiplayer)
var current_action
var current_inventory
var current_player
var label
var mouse_position
var obj_under_mouse

# What we want to avoid when pointing, it is loaded in the ready function
var avoid

# Other variables related to the point and click
var world
var camera
var players
var viewport
var ACTIONS
var idx_current_action = 0

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)


func init(_world, _viewport, _avoid, _players):
	avoid = _avoid
	viewport = _viewport
	camera = viewport.get_camera()
	current_player = _players[0]
	world = _world
	
	var base_dir = self.get_script().get_path().get_base_dir()
	ACTIONS = load(base_dir + "/actions.gd").new()
	
	label = get_node("GUI/Cursor Label")
	label.set("custom_colors/default_color", Color(1, 1, 1, 1))
	
	current_action = ACTIONS.none
	
	current_player.inventory = $GUI/Inventory
	current_player.camera = camera
	current_inventory = current_player.inventory


func get_object_under_mouse(mouse_pos):
	# Function to retrieve which object is under the mouse...
	var RAY_LENGTH = 50
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var selection = world.direct_space_state.intersect_ray(from, to, avoid)

	# If the ray hits something, the hitted object is at selection['collider']
	if not selection.empty() and selection['collider'].get("actions"):
		return selection['collider']
	else:
		return


func point():
	# On every single frame we check what's under the mouse
	label.rect_position = mouse_position + mouse_offset
	label.text =  current_action.text
	
	if obj_under_mouse:
		if current_action.type != ACTIONS.COMBINED:
			var actions = obj_under_mouse.actions
			current_action = actions[idx_current_action % actions.size()]
			label.text =  current_action.text

		label.text += " " + str(obj_under_mouse.name).to_lower()
	else:
		if current_action.type != ACTIONS.COMBINED:
			current_action = ACTIONS.none


func click():
	# Function called when a click is made
	if obj_under_mouse:
		match current_action.type:
			ACTIONS.IMMEDIATE:
				current_player.call(current_action.function, obj_under_mouse)
			ACTIONS.TO_COMBINE:
				# Combine action with this object
				current_action.combine(obj_under_mouse)
			ACTIONS.COMBINED:
				# Action that carries an object
				current_player.call(current_action.function,
									current_action.object,
									obj_under_mouse)
				current_action.uncombine()
	else:
		current_action.uncombine()

	idx_current_action = 0


func change_action(dir):
	# Change action to be used in the objects
	current_action.uncombine()
	idx_current_action += dir


func change_to_camera(_camera):
	# Switch to _camera
	_camera.current = true
	camera = viewport.get_camera()
	current_player.camera = camera


func _process(_delta):
	# Get mouse position
	mouse_position = viewport.get_mouse_position()
	
	# Check if there is an object under the mouse
	if current_inventory.position_contained(mouse_position):
		obj_under_mouse = current_inventory.get_object_in_position(mouse_position)
	else:
		obj_under_mouse = get_object_under_mouse(mouse_position)

	# Modify actions based on user input
	if Input.is_action_just_released("ui_wheel_up"):
		change_action(1)

	if Input.is_action_just_released("ui_wheel_down"):
		change_action(-1)

	# Change label depending on what is under the mouse
	point()
	
	# Manage the click
	if Input.is_action_just_released("ui_click"):
		click()
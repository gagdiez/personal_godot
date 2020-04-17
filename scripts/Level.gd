extends Spatial

onready var viewport = get_viewport()
onready var camera = viewport.get_camera()
onready var world = get_world()
onready var navigation = get_node('Navigation')
onready var label = get_node('Cursor Label')

# This is a point and click game, sounds fair to have all the time
# in mind where is mouse, and which object is under it
var mouse_position
var obj_under_mouse 

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)

# There should be a couple of actions: walk_to, read, look_at, take
const READ = 'read'
const WALK = 'walk_to'
const LOOK = 'look'
const TAKE = 'take'

const ACTIONS = [READ, WALK, LOOK, TAKE]
const properties_needed = {READ: "written_text", WALK: "position",
						   LOOK: "description", TAKE: "take_position"}

var current_click_action = WALK

# For debugging
var DEBUG = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_object_under_mouse(mouse_pos):
	# Function to retrieve which object is under the mouse...
	var RAY_LENGTH = 100
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var avoid = get_node('House/Walls').get_children()

	var selection = world.direct_space_state.intersect_ray(from, to, avoid)
	
	# If the ray hits something, then selection has a dictionary, with a
	# bunch of properties refering to the same object:
	
	#{position: Vector2 # point in world space for collision
	# normal: Vector2 # normal in world space for collision
	# collider: Object # Object collided or null (if unassociated)
	# collider_id: ObjectID # Object it collided against
	# rid: RID # RID it collided against
	# shape: int # shape index of collider
	# metadata: Variant()} # metadata of collider
	
	if not selection.empty():
		return selection['collider']
	else:
		return

func point():
	# On every single frame we check what's under the mouse
	# Right now we only show the name of the object (if any)
	# in the future we could change the cursor (to denote interaction)
	# or maybe display a menu... or something
	if obj_under_mouse: 
		label.rect_position = mouse_position + mouse_offset
		label.text = current_click_action + " " + str(obj_under_mouse.name)
	else:
		label.text = ""

func click():
	# Function called when something was clicked
	if obj_under_mouse:
		if obj_under_mouse.get(properties_needed[current_click_action]):
			# If the object has the properties needed for the
			# current action, then Cole performs it
			$Cole.call(current_click_action, obj_under_mouse)

func change_action(dir):
	var idx_current_action = ACTIONS.find(current_click_action)
	idx_current_action = (idx_current_action + dir) % ACTIONS.size()
	current_click_action = ACTIONS[idx_current_action]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	mouse_position = viewport.get_mouse_position()
	obj_under_mouse = get_object_under_mouse(mouse_position)
	
	if Input.is_action_just_released("ui_weel_up"):
		change_action(1)
	
	if Input.is_action_just_released("ui_weel_down"):
		change_action(-1)
	
	point()

	if Input.is_action_just_released("ui_click"):
		click()
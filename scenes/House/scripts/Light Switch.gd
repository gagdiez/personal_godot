extends 'Interactive.gd'

func _ready():
	actions = [ACTIONS.use]

func use(who):
	$OmniLight.visible = not $OmniLight.visible
	$light_glow.visible = not $light_glow.visible

extends Player

func _ready():
	._ready()

	animation_player = $Animations

	talk_bubble = $"Talk Bubble"
	talk_bubble.visible = false

	talk_bubble_timer = $"Talk Bubble/Timer"

	talk_bubble_offset = Vector3(-.6, 9.5, 0)
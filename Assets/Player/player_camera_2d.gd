extends Camera2D

@onready var player: Player = %Player

func _process(_delta: float) -> void:
	position = player.position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom < Vector2(2, 2):
				zoom += Vector2(0.035, 0.035)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom > Vector2(1, 1):
				zoom -= Vector2(0.035, 0.035)

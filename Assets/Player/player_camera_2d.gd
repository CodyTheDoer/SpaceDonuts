extends Camera2D

@onready var player: Player = %Player
@onready var donut_exterior_map: Control = $".."

func _process(_delta: float) -> void:
	position = player.position

func _set_current_camera_zoom(camera_zoom: float) -> void:
	zoom = Vector2(camera_zoom, camera_zoom)

extends CanvasLayer

@export var space_donut: SpaceDonut
@export var player_indicator_res: SpaceDonut3DLocationIndicator

@onready var donut_interior_map = %DonutInteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator

@onready var space = %Space
@onready var orbit_slider = %OrbitSlider
@onready var player_zoom_slider = %PlayerZoomSlider

func _process(delta: float) -> void:
	update_2d_gui_location_indicators()
	update_3d_gui_camera_orbit(delta)

func update_2d_gui_location_indicators():
	height_indicator.value = (donut_interior_map.player_coords.y / ( space_donut.ring_world_y_max * 32 ) * 100) * -1 + 100
	width_indicator.value = donut_interior_map.player_coords.x / ( space_donut.ring_world_x_max * 32 ) * 100

func update_3d_gui_camera_orbit(delta: float):
	for node in get_tree().get_nodes_in_group("Camera3DOrbit"):
		node.rotation.y = lerp(node.rotation.y, orbit_slider.value / 58, delta)

func update_zoom_slider_to_match_player_zoom(camera_zoom: float) -> void:
	player_zoom_slider.value = camera_zoom
	print("camera_zoom: ", camera_zoom)

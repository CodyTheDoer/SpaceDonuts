extends CanvasLayer

@export var space_donut: SpaceDonutInterior
@export var player_indicator_res: SpaceDonut3DLocationIndicator
@export var current_2d_zoom: float
@export var current_3d_rotation: int
@export var player_location: Vector2
@export var inner_ringworld_reference_map: Array[Array]
@export var player_interface_map: Array
@export var currently_tiling: bool
@export var tile_queue: Array
@export var previous_tile_queue_size: int

@onready var donut_interior_map = %DonutInteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator
@onready var _2d_map_viewport_container: SubViewportContainer = %"2DMapViewportContainer"

@onready var space = %Space
@onready var orbit_slider = %OrbitSlider
@onready var player_zoom_slider = %PlayerZoomSlider

func _process(delta: float) -> void:
	update_2d_gui_location_indicators()
	update_3d_gui_camera_orbit(delta)
	#update_player_location_export()

func update_player_location_export():
	player_location = _2d_map_viewport_container.player_coords

func update_2d_gui_location_indicators():
	height_indicator.value = (donut_interior_map.player_coords.y / ( space_donut.ring_world_y_max * 32 ) * 100) * -1 + 100
	width_indicator.value = donut_interior_map.player_coords.x / ( space_donut.ring_world_x_max * 32 ) * 100

func update_3d_gui_camera_orbit(delta: float):
	for node in get_tree().get_nodes_in_group("Camera3DOrbit"):
		node.rotation.y = lerp(node.rotation.y, orbit_slider.value / 58, delta)
	current_3d_rotation = orbit_slider.value

func update_zoom_slider_to_match_player_zoom(camera_zoom: float) -> void:
	player_zoom_slider.value = camera_zoom
	current_2d_zoom = camera_zoom
	#print("camera_zoom: ", camera_zoom)

func load_player_name(player_name):
	pass

func load_space_donut(space_donut):
	pass

func load_player_location(player_location):
	pass

func load_player_indicator_res(player_indicator_res):
	pass

func load_current_2d_zoom(current_2d_zoom):
	pass

func load_current_3d_rotation(current_3d_rotation):
	pass

func load_inner_ringworld_reference_map(inner_ringworld_reference_map):
	pass

func load_player_interface_map(player_interface_map):
	pass

func load_currently_tiling(currently_tiling):
	pass

func load_tile_queue(tile_queue):
	pass

func load_previous_tile_queue_size(previous_tile_queue_size):
	pass


#@export var space_donut: SpaceDonut
#@export var player_indicator_res: SpaceDonut3DLocationIndicator
#@export var current_2d_zoom: float
#@export var current_3d_rotation: int
#@export var player_location: Vector2
#@export var inner_ringworld_reference_map: Array[Array]
#@export var player_interface_map: Array
#@export var currently_tiling: bool
#@export var tile_queue: Array
#@export var previous_tile_queue_size: int

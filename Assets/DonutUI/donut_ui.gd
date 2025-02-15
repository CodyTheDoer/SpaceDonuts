extends CanvasLayer

@export var space_donut_interior: SpaceDonutInterior
@export var space_donut_exterior: SpaceDonutExterior
@export var player_indicator_res: SpaceDonut3DLocationIndicator
@export var current_2d_zoom: float
@export var current_3d_rotation: int
@export var player_location: Vector2
@export var internal_donut_reference_map: Array[Array]
@export var internal_player_interface_map: Array
@export var internal_currently_tiling: bool
@export var internal_tile_queue: Array
@export var internal_previous_tile_queue_size: int
@export var external_donut_reference_map: Array[Array]
@export var external_player_interface_map: Array
@export var external_currently_tiling: bool
@export var external_tile_queue: Array
@export var external_previous_tile_queue_size: int

signal update_player_position_donut_ui(position: Vector2)

@onready var player_name_label: Label = %PlayerNameLabel
@onready var donut_interior_map: Control = %DonutInteriorMap
@onready var donut_exterior_map: Control = %DonutExteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator
@onready var _2d_map_viewport_container: SubViewportContainer = %"2DMapViewportContainer"

@onready var space = %Space
@onready var orbit_slider = %OrbitSlider
@onready var player_zoom_slider = %PlayerZoomSlider

func _process(delta: float) -> void:
	update_2d_gui_location_indicators()
	update_3d_gui_camera_orbit(delta)
	update_player_location_export()

func update_player_location_export():
	player_location = donut_interior_map.player_coords

func update_2d_gui_location_indicators():
	height_indicator.value = (donut_interior_map.player_coords.y / ( space_donut_interior.ring_world_y_max * 32 ) * 100) * -1 + 100
	width_indicator.value = donut_interior_map.player_coords.x / ( space_donut_interior.ring_world_x_max * 32 ) * 100

func update_3d_gui_camera_orbit(delta: float):
	for node in get_tree().get_nodes_in_group("Camera3DOrbit"):
		node.rotation.y = lerp(node.rotation.y, orbit_slider.value / 58, delta)
	current_3d_rotation = orbit_slider.value

func update_zoom_slider_to_match_player_zoom(camera_zoom: float) -> void:
	player_zoom_slider.value = camera_zoom
	current_2d_zoom = camera_zoom

func load_player_name(load_player_name: String):
	print("load_player_name")
	player_name_label.text = load_player_name

func load_space_donut_interior(load_space_donut_interior: SpaceDonutInterior):
	print("load_space_donut_interior")
	space_donut_interior = load_space_donut_interior

func load_space_donut_exterior(load_space_donut_exterior: SpaceDonutExterior):
	print("load_space_donut_exterior")
	space_donut_exterior = load_space_donut_exterior

func load_player_location(load_player_location: Vector2):
	print("load_player_location")
	emit_signal("update_player_position_donut_ui", load_player_location)

func load_player_indicator_res(load_player_indicator_res: SpaceDonut3DLocationIndicator):
	print("load_player_indicator_res")
	player_indicator_res = load_player_indicator_res

func load_current_2d_zoom(load_current_2d_zoom: float):
	print("load_current_2d_zoom")
	player_zoom_slider.value = load_current_2d_zoom

func load_current_3d_rotation(load_current_3d_rotation: int):
	print("load_current_3d_rotation")
	current_3d_rotation = load_current_3d_rotation

func load_internal_donut_reference_map(load_internal_donut_reference_map: Array[Array]):
	print("load_internal_donut_reference_map")
	internal_donut_reference_map = load_internal_donut_reference_map

func load_internal_player_interface_map(load_internal_player_interface_map: Array):
	print("load_internal_player_interface_map")
	internal_player_interface_map = load_internal_player_interface_map

func load_internal_currently_tiling(load_internal_currently_tiling: bool):
	print("load_internal_currently_tiling")
	internal_currently_tiling = load_internal_currently_tiling

func load_internal_tile_queue(load_internal_tile_queue: Array):
	print("load_internal_tile_queue")
	internal_tile_queue = load_internal_tile_queue

func load_internal_previous_tile_queue_size(load_internal_previous_tile_queue_size: int):
	print("load_internal_previous_tile_queue_size")
	internal_previous_tile_queue_size = load_internal_previous_tile_queue_size

func load_external_donut_reference_map(load_external_donut_reference_map: Array[Array]):
	print("load_external_donut_reference_map")
	external_donut_reference_map = load_external_donut_reference_map

func load_external_player_interface_map(load_external_player_interface_map: Array):
	print("load_external_player_interface_map")
	external_player_interface_map = load_external_player_interface_map

func load_external_currently_tiling(load_external_currently_tiling: bool):
	print("load_external_currently_tiling")
	external_currently_tiling = load_external_currently_tiling

func load_external_tile_queue(load_external_tile_queue: Array):
	print("load_external_tile_queue")
	external_tile_queue = load_external_tile_queue

func load_external_previous_tile_queue_size(load_external_previous_tile_queue_size: int):
	print("load_external_previous_tile_queue_size")
	external_previous_tile_queue_size = load_external_previous_tile_queue_size

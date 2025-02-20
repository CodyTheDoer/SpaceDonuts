extends CanvasLayer

@export var space_donut_interior: SpaceDonutInterior
@export var space_donut_exterior: SpaceDonutExterior
@export var player_indicator_res: SpaceDonut3DLocationIndicator
@export var current_2d_zoom: float
@export var current_3d_rotation: int
@export var donut_reference_view_selection: int = 0
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

@onready var player_name_label: Label = %PlayerNameLabel
@onready var donut_interior_map: Control = %DonutInteriorMap
@onready var donut_exterior_map: Control = %DonutExteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator

@onready var space = %Space
@onready var orbit_slider = %OrbitSlider
@onready var player_zoom_slider = %PlayerZoomSlider

@onready var interior_animation_player: AnimationPlayer = %InteriorAnimationPlayer
@onready var exterior_animation_player: AnimationPlayer = %ExteriorAnimationPlayer
@onready var _3d_animation_player: AnimationPlayer = %"3DAnimationPlayer"
var startup_animation_played: bool = false

@onready var surface_tab: Control = %Surface
@onready var exterior_tab: Control = %Exterior

signal donut_interior_load_reference_map(load_internal_donut_reference_map: Array[Array])
signal donut_exterior_load_reference_map(load_external_donut_reference_map: Array[Array])
signal donut_interior_load_player_interface_map(load_internal_player_interface_map: Array)
signal donut_exterior_load_player_interface_map(load_external_player_interface_map: Array)
signal update_player_position_donut_ui(position: Vector2)

func _process(delta: float) -> void:
	if !startup_animation_played:
		start_up_animation_2d()
		start_up_animation_3d()
		startup_animation_played = true
	update_2d_gui_location_indicators()
	update_3d_gui_camera_orbit(delta)
	update_player_location_export()
	update_export_active_2d_tab()
	update_export_internal_donut_reference_map()
	update_export_external_donut_reference_map()
	update_export_load_internal_player_interface_map()
	update_export_load_external_player_interface_map()

func update_export_internal_donut_reference_map():
	internal_donut_reference_map = donut_interior_map.ring_world_interior_reference_map

func update_export_external_donut_reference_map():
	external_donut_reference_map = donut_exterior_map.ring_world_exterior_reference_map

func update_export_load_internal_player_interface_map():
	internal_player_interface_map = donut_interior_map.player_interface_mapped_targets

func update_export_load_external_player_interface_map():
	external_player_interface_map = donut_exterior_map.player_interface_mapped_targets

func update_export_active_2d_tab():
	if surface_tab.visible == true:
		donut_reference_view_selection = 0
	if exterior_tab.visible == true:
		donut_reference_view_selection = 1

func start_up_animation_2d():
	interior_animation_player.play("FadeIn")
	exterior_animation_player.play("FadeIn")

func start_up_animation_3d():
	_3d_animation_player.play("FadeIn")

func update_player_location_export():
	player_location = donut_interior_map.player_coords

func update_2d_gui_location_indicators():
	height_indicator.value = (donut_interior_map.player_coords.y / ( space_donut_interior.ring_world_y_max * 32 ) * 100) * -1 + 100
	if surface_tab.visible == true:
		width_indicator.value = donut_interior_map.player_coords.x / ( space_donut_interior.ring_world_x_max * 32 ) * 100
	if exterior_tab.visible == true:
		var original_value = donut_interior_map.player_coords.x / ( space_donut_interior.ring_world_x_max * 32 ) * 100
		var reverse_value = original_value * -1 + 100
		width_indicator.value = reverse_value

func update_3d_gui_camera_orbit(delta: float):
	for node in get_tree().get_nodes_in_group("Camera3DOrbit"):
		node.rotation.y = lerp(node.rotation.y, orbit_slider.value / 58, delta)
	current_3d_rotation = orbit_slider.value

func update_zoom_slider_to_match_player_zoom(camera_zoom: float) -> void:
	player_zoom_slider.value = camera_zoom
	current_2d_zoom = camera_zoom

func load_player_name(load_player_name: String):
	print("load_player_name: ", load_player_name)
	player_name_label.text = load_player_name

func load_space_donut_interior(load_space_donut_interior: SpaceDonutInterior):
	print("load_space_donut_interior: ", load_space_donut_interior)
	space_donut_interior = load_space_donut_interior

func load_space_donut_exterior(load_space_donut_exterior: SpaceDonutExterior):
	print("load_space_donut_exterior: ", load_space_donut_exterior)
	space_donut_exterior = load_space_donut_exterior

func load_player_location(load_player_location: Vector2):
	print("load_player_location: ", load_player_location)
	emit_signal("update_player_position_donut_ui", load_player_location)

func load_player_indicator_res(load_player_indicator_res: SpaceDonut3DLocationIndicator):
	print("load_player_indicator_res: ", load_player_indicator_res)
	player_indicator_res = load_player_indicator_res

func load_current_2d_zoom(load_current_2d_zoom: float):
	print("load_current_2d_zoom: ", load_current_2d_zoom)
	player_zoom_slider.value = load_current_2d_zoom

func load_current_3d_rotation(load_current_3d_rotation: int):
	print("load_current_3d_rotation: ", load_current_3d_rotation)
	orbit_slider.value = load_current_3d_rotation

func load_donut_reference_view_selection(donut_reference_view_selection: int):
	print("load_donut_reference_view_selection: ", donut_reference_view_selection)
	if donut_reference_view_selection == 0:
		surface_tab.visible = true
	if donut_reference_view_selection == 1:
		exterior_tab.visible = true

func load_internal_donut_reference_map(load_internal_donut_reference_map: Array[Array]):
	print("DonutUI: load_internal_donut_reference_map")
	emit_signal("donut_interior_load_reference_map", load_internal_donut_reference_map)

func load_internal_player_interface_map(load_internal_player_interface_map: Array):
	print("load_internal_player_interface_map")
	emit_signal("donut_interior_load_player_interface_map", load_internal_player_interface_map)

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
	emit_signal("donut_exterior_load_reference_map", load_external_donut_reference_map)

func load_external_player_interface_map(load_external_player_interface_map: Array):
	print("load_external_player_interface_map")
	emit_signal("donut_exterior_load_player_interface_map", load_external_player_interface_map)

func load_external_currently_tiling(load_external_currently_tiling: bool):
	print("load_external_currently_tiling")
	#external_currently_tiling = load_external_currently_tiling

func load_external_tile_queue(load_external_tile_queue: Array):
	print("load_external_tile_queue")
	#external_tile_queue = load_external_tile_queue

func load_external_previous_tile_queue_size(load_external_previous_tile_queue_size: int):
	print("load_external_previous_tile_queue_size")
	#external_previous_tile_queue_size = load_external_previous_tile_queue_size

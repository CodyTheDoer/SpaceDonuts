extends CanvasLayer

@export var space_donut: SpaceDonut
@export var player_indicator_res: SpaceDonut3DLocationIndicator

@onready var donut_interior_map = %DonutInteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator

#@onready var player = %Player
#@onready var player_indicator = %PlayerIndicator

@onready var space = %Space
@onready var orbit_slider = %OrbitSlider
	
func _process(delta: float) -> void:
	update_2d_gui_location_indicators()
	update_3d_gui_camera_orbit(delta)

func update_2d_gui_location_indicators():
	height_indicator.value = (donut_interior_map.player_coords.y / ( space_donut.ring_world_y_max * 32 ) * 100) * -1 + 100
	width_indicator.value = donut_interior_map.player_coords.x / ( space_donut.ring_world_x_max * 32 ) * 100

func update_3d_gui_camera_orbit(delta: float):
	for node in get_tree().get_nodes_in_group("Camera3DOrbit"):
		node.rotation.y = lerp(node.rotation.y, orbit_slider.value / 58, delta)
#
#func update_3d_gui_player_location_indicator():	
	#player_indicator_res.target_location = donut_interior_map.player_coords
	#player_indicator_res.donut_x_count = space_donut.ring_world_x_max
	#player_indicator_res.donut_y_count = space_donut.ring_world_y_max
	#
	#var y_rotation: Vector3 = player_indicator_res.y_rotation_degrees
	#var x_shifted_y_position: int = player_indicator_res.x_shifted_y_position
	#player_indicator.rotation_degrees = y_rotation
	#player_indicator.position.y = x_shifted_y_position

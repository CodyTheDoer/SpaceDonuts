extends Node3D

@export var space_donut: SpaceDonut
@export var player_indicator_res: SpaceDonut3DLocationIndicator

@onready var donut_interior_map = %DonutInteriorMap
@onready var height_indicator = %PlayerMapHeightIndicator
@onready var width_indicator = %PlayerMapWidthIndicator
@onready var player_indicator = %PlayerIndicator
@onready var player: Player

func _ready() -> void:
	main_player_prep()

func _process(_delta: float) -> void:
	player_indicator_res.display()
	update_3d_gui_player_location_indicator()

func main_player_prep():
	player_indicator.location_resource = player_indicator_res
	player_indicator_res.donut_x_count = space_donut.ring_world_x_max
	player_indicator_res.donut_y_count = space_donut.ring_world_y_max
	for main_player in get_tree().get_nodes_in_group("Player"):
		player = main_player

func update_3d_gui_player_location_indicator():
	player_indicator_res.target_location = donut_interior_map.player_coords
	
	var y_rotation: Vector3 = player_indicator_res.y_rotation_degrees
	var x_shifted_y_position: float = player_indicator_res.x_shifted_y_position
	#print(y_rotation, ", ", x_shifted_y_position)
	
	player_indicator.rotation_degrees = y_rotation
	player_indicator.position.y = x_shifted_y_position

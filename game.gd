extends Node2D

@onready var donut_ui: CanvasLayer = %DonutUI

var player_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_save():
	var config = ConfigFile.new()
	# Load data from a file.
	var err = config.load("user://game_save.cfg")
	# If the file didn't load, ignore it.
	if err != OK:
		return
	# Iterate over all sections.
	for game in config.get_sections():
		# Fetch the data for each section.
		var player_name = config.get_value(game, "player_name")
		var space_donut = config.get_value(game, "space_donut")
		var player_location = config.get_value(game, "player_location")
		var player_indicator_res = config.get_value(game, "player_indicator_res")
		var current_2d_zoom = config.get_value(game, "current_2d_zoom")
		var current_3d_rotation = config.get_value(game, "current_3d_rotation")
		var inner_ringworld_reference_map = config.get_value(game, "inner_ringworld_reference_map")
		var player_interface_map = config.get_value(game, "player_interface_map")
		var currently_tiling = config.get_value(game, "currently_tiling")
		var tile_queue = config.get_value(game, "tile_queue")
		var previous_tile_queue_size = config.get_value(game, "previous_tile_queue_size")
		
		donut_ui.load_player_name(player_name)
		donut_ui.load_space_donut(space_donut)
		donut_ui.load_player_location(player_location)
		donut_ui.load_player_indicator_res(player_indicator_res)
		donut_ui.load_current_2d_zoom(current_2d_zoom)
		donut_ui.load_current_3d_rotation(current_3d_rotation)
		donut_ui.load_inner_ringworld_reference_map(inner_ringworld_reference_map)
		donut_ui.load_player_interface_map(player_interface_map)
		donut_ui.load_currently_tiling(currently_tiling)
		donut_ui.load_tile_queue(tile_queue)
		donut_ui.load_previous_tile_queue_size(previous_tile_queue_size)

func save():
	var config = ConfigFile.new()
	config.set_value("game", "player_name", player_name)
	config.set_value("game", "space_donut", donut_ui.space_donut)
	config.set_value("game", "player_location", donut_ui.player_location)
	config.set_value("game", "player_indicator_res", donut_ui.player_indicator_res)
	config.set_value("game", "current_2d_zoom", donut_ui.current_2d_zoom)
	config.set_value("game", "current_3d_rotation", donut_ui.current_3d_rotation)
	config.set_value("game", "inner_ringworld_reference_map", donut_ui.inner_ringworld_reference_map)
	config.set_value("game", "player_interface_map", donut_ui.player_interface_map)
	config.set_value("game", "currently_tiling", donut_ui.currently_tiling)
	config.set_value("game", "tile_queue", donut_ui.tile_queue)
	config.set_value("game", "previous_tile_queue_size", donut_ui.previous_tile_queue_size)
	# Save it to a file (overwrite if already exists).
	config.save("user://game_save.cfg")

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

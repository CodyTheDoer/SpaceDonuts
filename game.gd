extends Control

@export var player_name: String

@onready var donut_ui: CanvasLayer = %DonutUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey:
		#print(event.keycode)
		if event.pressed and event.keycode == KEY_ESCAPE:
			save()
			get_tree().quit()

func load_save():
	var config = ConfigFile.new()
	# Load data from a file.
	var err = config.load("game_save.cfg")
	# If the file didn't load, ignore it.
	if err != OK:
		print("Save failed to load...")
		return
	print("Save loaded...")
	# Iterate over all sections.
	for game in config.get_sections():
		# Fetch the data for each section.
		var player_name = config.get_value(game, "player_name")
		var space_donut_interior = config.get_value(game, "space_donut_interior")
		var space_donut_exterior = config.get_value(game, "space_donut_exterior")
		var player_location = config.get_value(game, "player_location")
		var player_indicator_res = config.get_value(game, "player_indicator_res")
		var current_2d_zoom = config.get_value(game, "current_2d_zoom")
		var current_3d_rotation = config.get_value(game, "current_3d_rotation")
		var internal_donut_reference_map = config.get_value(game, "internal_donut_reference_map")
		var internal_player_interface_map = config.get_value(game, "internal_player_interface_map")
		var internal_currently_tiling = config.get_value(game, "internal_currently_tiling")
		var internal_tile_queue = config.get_value(game, "internal_tile_queue")
		var internal_previous_tile_queue_size = config.get_value(game, "internal_previous_tile_queue_size")
		var external_donut_reference_map = config.get_value(game, "external_donut_reference_map")
		var external_player_interface_map = config.get_value(game, "external_player_interface_map")
		var external_currently_tiling = config.get_value(game, "external_currently_tiling")
		var external_tile_queue = config.get_value(game, "external_tile_queue")
		var external_previous_tile_queue_size = config.get_value(game, "external_previous_tile_queue_size")
		
		donut_ui.load_player_name(player_name)
		donut_ui.load_space_donut_interior(space_donut_interior)
		donut_ui.load_space_donut_exterior(space_donut_exterior)
		donut_ui.load_player_location(player_location)
		donut_ui.load_player_indicator_res(player_indicator_res)
		donut_ui.load_current_2d_zoom(current_2d_zoom)
		donut_ui.load_current_3d_rotation(current_3d_rotation)
		donut_ui.load_internal_donut_reference_map(internal_donut_reference_map)
		donut_ui.load_internal_player_interface_map(internal_player_interface_map)
		donut_ui.load_internal_currently_tiling(internal_currently_tiling)
		donut_ui.load_internal_tile_queue(internal_tile_queue)
		donut_ui.load_internal_previous_tile_queue_size(internal_previous_tile_queue_size)
		donut_ui.load_external_donut_reference_map(external_donut_reference_map)
		donut_ui.load_external_player_interface_map(external_player_interface_map)
		donut_ui.load_external_currently_tiling(external_currently_tiling)
		donut_ui.load_external_tile_queue(external_tile_queue)
		donut_ui.load_external_previous_tile_queue_size(external_previous_tile_queue_size)

func save():
	var config = ConfigFile.new()
	config.set_value("game", "player_name", player_name)
	config.set_value("game", "space_donut_interior", donut_ui.space_donut_interior)
	config.set_value("game", "space_donut_exterior", donut_ui.space_donut_exterior)
	config.set_value("game", "player_location", donut_ui.player_location)
	config.set_value("game", "player_indicator_res", donut_ui.player_indicator_res)
	config.set_value("game", "current_2d_zoom", donut_ui.current_2d_zoom)
	config.set_value("game", "current_3d_rotation", donut_ui.current_3d_rotation)
	print(donut_ui.internal_donut_reference_map)
	config.set_value("game", "internal_donut_reference_map", donut_ui.internal_donut_reference_map)
	print(donut_ui.internal_player_interface_map)
	config.set_value("game", "internal_player_interface_map", donut_ui.internal_player_interface_map)
	print(donut_ui.internal_currently_tiling)
	config.set_value("game", "internal_currently_tiling", donut_ui.internal_currently_tiling)
	print(donut_ui.internal_tile_queue)
	config.set_value("game", "internal_tile_queue", donut_ui.internal_tile_queue)
	print(donut_ui.internal_previous_tile_queue_size)
	config.set_value("game", "internal_previous_tile_queue_size", donut_ui.internal_previous_tile_queue_size)
	print(donut_ui.external_donut_reference_map)
	config.set_value("game", "external_donut_reference_map", donut_ui.external_donut_reference_map)
	print(donut_ui.external_player_interface_map)
	config.set_value("game", "external_player_interface_map", donut_ui.external_player_interface_map)
	print(donut_ui.external_currently_tiling)
	config.set_value("game", "external_currently_tiling", donut_ui.external_currently_tiling)
	print(donut_ui.external_tile_queue)
	config.set_value("game", "external_tile_queue", donut_ui.external_tile_queue)
	print(donut_ui.external_previous_tile_queue_size)
	config.set_value("game", "external_previous_tile_queue_size", donut_ui.external_previous_tile_queue_size)
	# Save it to a file (overwrite if already exists).
	config.save("game_save.cfg")
	print("Save process complete...")

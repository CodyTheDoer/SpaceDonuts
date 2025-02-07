extends Node2D

@onready var target_area_map_layer: TileMapLayer = $TargetAreaMapLayer
@onready var tilemap: TileMapLayer = %DonutTileMapLayer
@onready var player: Player = %Player

@export var ring_world: SpaceDonut
@export var player_coords: Vector2i

var active_tile_map: Array[Array] = []
var ring_world_reference_map: Array[Array] = []
var player_tile_pos: Vector2i
var tile_size: int = 32
var world_x_max: int
var world_y_max: int
var display_radius: int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_ring_world_x_and_y()
	build_ringworld_maps()
	gen_active_tile_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_player_tile_pos()
	display_tiles_in_radius()
	montor_and_move_player_when_crossing_y_bounds()
	update_export_player_coords()
	monitor_player_click_and_drag_for_target_area()

# // --- _ready() --- //
func set_ring_world_x_and_y():
	var x_max = ring_world.ring_world_x_max
	var y_max = ring_world.ring_world_y_max
	world_x_max = x_max
	world_y_max = y_max

func build_ringworld_maps():
	ring_world.build_if_new()
	ring_world_reference_map = ring_world.tile_map

func gen_active_tile_map():
	for x in range(0 , world_x_max):
		active_tile_map.append([])
		for y in range(0 , world_y_max):
			active_tile_map[x].append(0)

# // --- _process() --- //
func update_player_tile_pos():
	var player_in_block = Vector2(player.position.x / tile_size as int, player.position.y / tile_size as int)
	player_tile_pos = player_in_block

func display_tiles_in_radius():
	var display_tiles = []
	var player_tile_pos = Vector2i(player.position / tile_size)  # Update tile size accordingly
	# Generate tiles within a radius
	for x in range(-display_radius, display_radius + 1):
		for y in range(-display_radius, display_radius + 1):
			if Vector2(x, y).length() <= display_radius:  # Check if within circle
				display_tiles.append(player_tile_pos + Vector2i(x, y))
	# Populate the tiles
	for tile in display_tiles:
		if tile.x > 0 and tile.y > 0:
			if tile.x < world_x_max and tile.y < world_y_max:
				tilemap.set_cell(tile, 1, ring_world_reference_map[tile.x][tile.y])
				active_tile_map[tile.x][tile.y] = 1
	# Prep to depopulate the tiles that aren't within the radius.
	var remove_tiles = []
	for x in range(0 , world_x_max):
		for y in range(0 , world_y_max):
			if active_tile_map[x][y] == 1:
				remove_tiles.append(Vector2i(x, y))
	# Filter to ensure we don't remove tiles withing sight radius
	for tile in display_tiles:
		remove_tiles.erase(tile)
	# Remove the tiles not within the radius
	for target in remove_tiles:
		tilemap.set_cell(target, -1)
		active_tile_map[target.x][target.y] = 0

func montor_and_move_player_when_crossing_y_bounds():
	if player_tile_pos.y > world_y_max:
		player.position.y = 0
	if player_tile_pos.y < 0:
		player.position.y = world_y_max * 32
	
func update_export_player_coords():
	player_coords = player.position
	#print(player_coords / Vector2i(32, 32))

func monitor_player_click_and_drag_for_target_area():
	var input_left_click = Input.is_action_just_pressed("left_click")
	var release_left_click = Input.is_action_just_released("left_click")
	var original_position: Vector2
	var release_position: Vector2
	if input_left_click:
		original_position = target_area_map_layer.local_to_map(get_viewport().get_mouse_position())
	if release_left_click:
		release_position = target_area_map_layer.local_to_map(get_viewport().get_mouse_position())
		print(original_position, release_position)

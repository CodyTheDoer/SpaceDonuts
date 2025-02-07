extends Node2D

@onready var tilemap = %DonutTileMapLayer
@onready var player = %Player

@export var ring_world: SpaceDonut
@export var player_coords: Vector2i

var tile_staging = {
	location : tile_type
}


var active_tile_map: Array[Array] = []
var tile_size: int = 32
var tile_value_reference: Array[Array] = []
var tile_type: Vector2i
var location: Vector2i
var player_pos: Vector2
var player_vision_radius: int = 2
var noise = FastNoiseLite.new()

func _ready() -> void:
	var world_x_max = ring_world.ring_world_x_max
	var world_y_max = ring_world.ring_world_y_max
	generate_initial_tilemap()
	map_generated_tiles()
	generate_extranious_tiling()
	generate_active_tile_map(world_x_max, world_y_max)
	initial_hide_all_tiles()

func _process(_delta: float) -> void:
	#var chunk_x = ring_world.ring_world_x_max / chunk_size
	#var chunk_y = ring_world.ring_world_y_max / chunk_size
	#chunk_handler(chunk_x, chunk_y)
	
	montor_and_move_player_when_crossing_y_bounds()
	update_export_player_coords()
	show_tiles_within_player_radius()
	update_extranious_tiling()

func initial_hide_all_tiles():
	for x in range(ring_world.ring_world_x_max):
		for y in range(ring_world.ring_world_y_max):
			tilemap.set_cell(Vector2i(x, y), -1)

func hide_tiles():
	pass
	#for x in range(ring_world.ring_world_x_max):
		#for y in range(ring_world.ring_world_y_max):
			#var source_id = tilemap.get_cell_source_id(Vector2i(x, y))
			#var tile_data = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			#tilemap.set_cell(Vector2i(x, y), source_id, tile_data)

func distance(p1, p2):
	var r = p1 - p2
	return sqrt(r.x ** 2 + r.y ** 2)

func show_tiles_within_player_radius():
	player_in_block()
	var tiles_within_player_radius = []
	for x in range(ring_world.ring_world_x_max):
		for y in range(ring_world.ring_world_y_max):
			var tile_position = Vector2(x, y)
			if player_pos.distance_to(tile_position) <= player_vision_radius:
				tiles_within_player_radius.append(tile_position)
	for tile in tiles_within_player_radius:
		tilemap.set_cell(tile, 0, tile_value_reference[tile.x][tile.y])
	print(tiles_within_player_radius)

func player_in_block():
	var player_in_block = Vector2(player.position.x / tile_size as int, player.position.y / tile_size as int)
	player_pos = player_in_block

#func chunk_handler(chunk_x, chunk_y):
	#var player_chunk_location = player.position / Vector2(chunk_size, chunk_size)

func generate_active_tile_map(world_x_max, chuworld_y_max):
	for x in range(world_x_max):
		active_tile_map.append([])
		for y in range(chuworld_y_max):
			active_tile_map[x].append(1)

func generate_initial_tilemap():
	var terrain_target = []
	for x in range(ring_world.ring_world_x_max):
		for y in range(ring_world.ring_world_y_max):
			terrain_target.append(Vector2i(x, y))
			#print("[ x: ", x, ", y: ", y, " ]")
	tilemap.set_cells_terrain_connect(terrain_target, 0, 0, false)

func map_generated_tiles():
	tile_value_reference.clear()
	for x in range(ring_world.ring_world_x_max):
		tile_value_reference.append([])
		for y in range(ring_world.ring_world_y_max):
			var tile_value = tilemap.get_cell_atlas_coords(Vector2(x, y))
			tile_value_reference[x].append(tile_value)

func generate_extranious_tiling():
	for x in range(ring_world.ring_world_x_max):
		for y in range(ring_world.ring_world_y_max):
			var source_id = tilemap.get_cell_source_id(Vector2i(x, y))
			var tile_data = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			tile_staging[Vector2i(x, y)] = tile_data
			tilemap.set_cell(Vector2i(x, y + ring_world.ring_world_y_max), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.ring_world_y_max), source_id, tile_data)

func montor_and_move_player_when_crossing_y_bounds():
	if player.position.y > ring_world.ring_world_y_max * 32:
		player.position.y = 0
	if player.position.y < 0:
		player.position.y = ring_world.ring_world_y_max * 32

func update_export_player_coords():
	player_coords = player.position

func update_extranious_tiling():
	for x in range(ring_world.ring_world_x_max):
		for y in range(ring_world.ring_world_y_max):
			var tile_data_ref = tile_staging[Vector2i(x, y)]
			var source_id = tilemap.get_cell_source_id(Vector2i(x, y))
			var tile_data = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			if tile_data != tile_data_ref: #only update ref tiling copies if original changed
				tile_staging[Vector2i(x, y)] = tile_data
				tilemap.set_cell(Vector2i(x, y + ring_world.ring_world_y_max), source_id, tile_data)
				tilemap.set_cell(Vector2i(x, y - ring_world.ring_world_y_max), source_id, tile_data)

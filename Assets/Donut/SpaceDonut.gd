class_name SpaceDonut
extends Resource

@export var world_name: String
@export var new_instance: bool = true
@export var ring_world_x_max: float
@export var ring_world_y_max: float
@export var tile_map: Array[Array] = []

const DIRT: int = 0
const FLOWERS: int = 1
const GRASS: int = 2
const ROCKY: int = 3
const TILLED: int = 4

var world_noise = FastNoiseLite.new()

var tile_asset_paths = {
	0 : "res://Assets/LandTile/LandTileAssets/DIRT.png",
	1 : "res://Assets/LandTile/LandTileAssets/FLOWERS.png",
	2 : "res://Assets/LandTile/LandTileAssets/GRASS.png",
	3 : "res://Assets/LandTile/LandTileAssets/ROCKY.png",
	4 : "res://Assets/LandTile/LandTileAssets/TILLED.png",
}

var tile_atlas_paths = {
	0 : Vector2i(0, 0),
	1 : Vector2i(2, 0),
	2 : Vector2i(3, 0),
	3 : Vector2i(4, 0),
	4 : Vector2i(1, 0),
}

func build_if_new():
	print("Checking if Tilemap is empty...")
	if !tile_map.is_empty():
		print("Tilemap already exists, skipping gen...")
		return
	print("Tilemap is empty...")
	var terrain_target = []
	for x in range(0, ring_world_x_max as int):
		tile_map.append([])
		for y in range(0, ring_world_y_max as int):
			terrain_target.append(Vector2i(x, y))
			var texture_float: float = world_noise.get_noise_2d(x, y)
			# Use noise value to set appropriate tile
			if texture_float > 0.75:
				tile_map[x].append(tile_atlas_paths[GRASS])
			elif texture_float > 0.50:
				tile_map[x].append(tile_atlas_paths[DIRT])
			elif texture_float > 0.25:
				tile_map[x].append(tile_atlas_paths[ROCKY])
			else:
				tile_map[x].append(tile_atlas_paths[FLOWERS])

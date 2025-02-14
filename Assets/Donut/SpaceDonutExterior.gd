class_name SpaceDonutExterior
extends Resource

@export var world_name: String
@export var new_instance: bool = true
@export var ring_world_x_max: float
@export var ring_world_y_max: float
@export var tile_map: Array[Array] = []

const METAL1: int = 0
const METAL2: int = 1
const METAL3: int = 2
const METAL4: int = 3
const METAL5: int = 4

var world_noise = FastNoiseLite.new()

var tile_asset_paths = {
	0 : "res://Assets/LandTile/LandTileAssets/METAL1.png",
	1 : "res://Assets/LandTile/LandTileAssets/METAL2.png",
	2 : "res://Assets/LandTile/LandTileAssets/METAL3.png",
	3 : "res://Assets/LandTile/LandTileAssets/METAL4.png",
	4 : "res://Assets/LandTile/LandTileAssets/METAL5.png",
}

var tile_atlas_paths = {
	0 : Vector2i(0, 0),
	1 : Vector2i(1, 0),
	2 : Vector2i(2, 0),
	3 : Vector2i(3, 0),
	4 : Vector2i(4, 0),
}

func build_if_new():
	world_noise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
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
				tile_map[x].append(tile_atlas_paths[METAL1])
			elif texture_float > 0.50:
				tile_map[x].append(tile_atlas_paths[METAL2])
			elif texture_float > 0.25:
				tile_map[x].append(tile_atlas_paths[METAL3])
			else:
				tile_map[x].append(tile_atlas_paths[METAL4])

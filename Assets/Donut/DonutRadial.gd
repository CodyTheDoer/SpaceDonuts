extends Resource

@export var RingInnerFaceCount: int
@export var RingDepth: int

var tile_asset_paths = {
	0 : "res://Assets/LandTile/LandTileAssets/DIRT.png",
	1 : "res://Assets/LandTile/LandTileAssets/FLOWERS.png",
	2 : "res://Assets/LandTile/LandTileAssets/GRASS.png",
	3 : "res://Assets/LandTile/LandTileAssets/ROCKY.png",
	4 : "res://Assets/LandTile/LandTileAssets/TILLED.png",
}

enum tile_type {
	DIRT,
	FLOWERS,
	GRASS,
	ROCKY,
	TILLED,
}

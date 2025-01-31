extends Node2D

@export var ring_world: Resource

@onready var tilemap = %DonutTileMapLayer
@onready var player = %Player

func _ready() -> void:	
	var terrain_target = []
	for x in range(ring_world.RingDepth):
		for y in range(ring_world.RingInnerFaceCount):
			terrain_target.append(Vector2i(x, y))
			print("[ x: ", x, ", y: ", y, " ]")
	tilemap.set_cells_terrain_connect(terrain_target, 0, 0, false)
	
	for x in range(ring_world.RingDepth):
		for y in range(ring_world.RingInnerFaceCount):
			var source_id = tilemap.get_cell_source_id(Vector2i(x, y))
			var tile_data = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			tilemap.set_cell(Vector2i(x, y + ring_world.RingInnerFaceCount), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.RingInnerFaceCount), source_id, tile_data)

			tilemap.set_cell(Vector2i(x, y + ring_world.RingInnerFaceCount * 2), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.RingInnerFaceCount * 2), source_id, tile_data)

			tilemap.set_cell(Vector2i(x, y + ring_world.RingInnerFaceCount * 3), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.RingInnerFaceCount * 3), source_id, tile_data)

			tilemap.set_cell(Vector2i(x, y + ring_world.RingInnerFaceCount * 4), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.RingInnerFaceCount * 4), source_id, tile_data)

			tilemap.set_cell(Vector2i(x, y + ring_world.RingInnerFaceCount * 5), source_id, tile_data)
			tilemap.set_cell(Vector2i(x, y - ring_world.RingInnerFaceCount * 5), source_id, tile_data)

func _process(delta: float) -> void:
	print(player.position)
	print(ring_world.RingInnerFaceCount)
	if player.position.y > ring_world.RingInnerFaceCount * 32:
		player.position.y = 0
	if player.position.y < 0:
		player.position.y = ring_world.RingInnerFaceCount * 32

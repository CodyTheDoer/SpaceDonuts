extends CanvasLayer

@export var ring_world: Resource 

@onready var tilemap = %DonutTileMapLayer

func _ready() -> void:	
	var terrain_target = []
	for x in range(ring_world.RingDepth):
		for y in range(ring_world.RingInnerFaceCount):
			terrain_target.append(Vector2i(x, y))
			print("[ x: ", x, ", y: ", y, " ]")
	tilemap.set_cells_terrain_connect(terrain_target, 0, 0, false)

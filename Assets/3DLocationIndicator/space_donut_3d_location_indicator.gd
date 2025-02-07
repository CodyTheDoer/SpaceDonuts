extends Node3D

@onready var LocationLightInner = %LocationLightInner
@onready var LocationLightOuter = %LocationLightOuter

@export var location_resource: SpaceDonut3DLocationIndicator

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	LocationLightInner.light_color = location_resource.light_Color
	LocationLightOuter.light_color = location_resource.light_Color

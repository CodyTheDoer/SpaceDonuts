class_name SpaceDonut3DLocationIndicator
extends Resource

@export var target_location: Vector2
@export var light_Color: Color
@export var donut_x_count: float
@export var donut_y_count: float
@export var y_rotation_degrees: Vector3
@export var x_shifted_y_position: float

func display():
	var y_normalized = target_location.y / (donut_y_count * 32)
	var y_scaled = y_normalized * 360
	var y_inverted = y_scaled * -1
	y_rotation_degrees = Vector3(0, y_inverted, 0)
	#var location_rotation_controller.rotation_degrees = Vector3(0, y_inverted, 0)
	
	var x_normalized = target_location.x / (donut_x_count * 32)
	var x_scaled = x_normalized * 4
	var x_shifted = x_scaled - 2
	x_shifted_y_position = x_shifted
	#location_rotation_controller.position.y = x_shifted
	
	#print("Running DISPLAY")
	#print("y_rotation_degrees: [ ", y_rotation_degrees, " ]")
	#print("x_shifted_y_position: [ ", x_shifted_y_position, " ]")

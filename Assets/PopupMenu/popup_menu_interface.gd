extends Node2D

@export var popup_soil_options_labels: SoilInteractionLabels
@export var options_array: Array
@export var antialiasing: bool = false
@export var distance_from_center: int = 120
@export var segment_gap: int = 5
@export var width: int = 12
@export var color: Color = Color.GREEN
@export var starting_point: Vector2 = Vector2.ZERO

var segments: int = 0

func _ready() -> void:
	if options_array.is_empty():
		options_array = popup_soil_options_labels.get_label_array()
	segments = len(options_array)  # Count the number of segments based on options

func _draw():
	draw_segments()

func draw_segments():
	if segments <= 0:
		return  # Avoid division by zero

	for segment in range(segments):
		# Calculate the angle for the current segment
		var single_segment_angle = (360 / segments) - segment_gap
		var segment_start_angle = ((single_segment_angle + segment_gap) * segment) + (segment_gap / 2)
		var segment_end_angle = segment_start_angle + single_segment_angle
		var segment_center_angle = (segment_start_angle + segment_end_angle) / 2
		print(segment_start_angle, ", ", segment_end_angle, ", ", segment_center_angle)

		# Convert angles to radians for calculations
		var start_x = distance_from_center * cos(deg_to_rad(segment_start_angle))
		var start_y = distance_from_center * sin(deg_to_rad(segment_start_angle))
		var center_x = (distance_from_center * 1.5) * cos(deg_to_rad(segment_center_angle)) - 20
		var center_y = (distance_from_center * 1.5) * sin(deg_to_rad(segment_center_angle))
		var end_x = distance_from_center * cos(deg_to_rad(segment_end_angle))
		var end_y = distance_from_center * sin(deg_to_rad(segment_end_angle))

		# Define points for the segment
		var p1: Vector2 = Vector2(start_x, start_y)
		var p2: Vector2 = Vector2(end_x, end_y)
		var extended_center_angle_point: Vector2 = Vector2(center_x, center_y)

		# Call the draw functions
		draw_arc_segment(p1, p2)
		draw_label(extended_center_angle_point, popup_soil_options_labels.get_label_array()[segment - 1])

func draw_label(p1: Vector2, label: String):
	print(draw_label)
	var new_label: Label = Label.new()
	new_label.text = label
	new_label.theme = load("res://Assets/Fonts/std_theme.tres") 
	new_label.position = p1
	new_label.set_anchors_preset(Control.PRESET_CENTER)
	add_child(new_label)  

func draw_arc_segment(p1: Vector2, p2: Vector2):
	print(draw_arc_segment)
	var center: Vector2 = Vector2.ZERO  # Drawing from (0,0)
	var start_angle = atan2(p1.y - center.y, p1.x - center.x)
	var end_angle = atan2(p2.y - center.y, p2.x - center.x)

	# Ensure angles are in the correct range
	if start_angle < 0:
		start_angle += TAU
	if end_angle < 0:
		end_angle += TAU

	# Draw the arc
	draw_arc(center, distance_from_center, start_angle, end_angle, 50, color, width, antialiasing)

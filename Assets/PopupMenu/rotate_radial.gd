extends Node2D

@export var segments: int
@export var distance_from_center: float
@export var segment_gap: float
@export var color: Color
@export var width: int
@export var antialiasing: bool

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
		var label_center_angle = (segment_start_angle + segment_end_angle) / 2
		
		# Convert angles to radians for calculations
		var start_x = distance_from_center * cos(deg_to_rad(segment_start_angle))
		var start_y = distance_from_center * sin(deg_to_rad(segment_start_angle))
		var end_x = distance_from_center * cos(deg_to_rad(segment_end_angle))
		var end_y = distance_from_center * sin(deg_to_rad(segment_end_angle))

		# Define points for the segment
		var p1: Vector2 = Vector2(start_x, start_y)
		var p2: Vector2 = Vector2(end_x, end_y)

		# Call the draw functions
		draw_arc_segment(p1, p2)

func draw_arc_segment(p1: Vector2, p2: Vector2):
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

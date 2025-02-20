extends Node2D

@onready var rotate_radial: Node2D = $rotate_radial
@onready var rotate_labels: Node2D = $rotate_labels

@export var options_array: Array
@export var antialiasing: bool = false
@export var distance_from_center: int = 120
@export var segment_gap: int = 5
@export var color: Color = Color.GREEN
@export var starting_point: Vector2 = Vector2.ZERO
@export var selection: int
@export var selection_confirmed: bool = false

var selection_direction: int # n/360 
var segments: int = 0

var _time : float = 0
var _popup_arc_width : float = 30
var _min_width : float = 30
var _max_width : float = 40
var target: float

const CANCEL = 0
const CABBAGE = 1
const CUCUMBER = 2
const ONION = 3
const PEPPER = 4
const POTATO = 5
const SUNFLOWER = 6
const TOMATO = 7
const WHEAT = 8

var label = {
	0: "CANCEL",
	1: "CABBAGE",
	2: "CUCUMBER",
	3: "ONION",
	4: "PEPPER",
	5: "POTATO",
	6: "SUNFLOWER",
	7: "TOMATO",
	8: "WHEAT",
}

func get_label_array():
	var label_array = [
		label[CANCEL],
		label[CABBAGE],
		label[CUCUMBER],
		label[ONION],
		label[PEPPER],
		label[POTATO],
		label[SUNFLOWER],
		label[TOMATO],
		label[WHEAT],
	]
	return label_array

func _ready() -> void:
	if options_array.is_empty():
		options_array = get_label_array()
		#print(options_array)
	segments = len(options_array)
	update_rotate_labels()

func _process(delta: float) -> void:
	update_rotate_radial()
	track_selection_direction()
	_time += delta

	_popup_arc_width = clamp(abs(sin(_time)) * (_max_width - _min_width) + _min_width, _min_width, _max_width)
	queue_redraw()
	rotate_radial.queue_redraw()

func update_rotate_radial():
	rotate_radial.segments = segments
	rotate_radial.distance_from_center = distance_from_center
	rotate_radial.segment_gap = segment_gap
	rotate_radial.color = color
	rotate_radial.width = _popup_arc_width
	rotate_radial.antialiasing = antialiasing

func update_rotate_labels():
	if segments == 1:
		var additional_rotation_ammount: int = 360 / segments / 2 + 180
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 2:
		var additional_rotation_ammount: int = 360 / segments / 2 + 175
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 3:
		var additional_rotation_ammount: int = 360 / segments / 2 - 90
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 4:
		var additional_rotation_ammount: int = 360 / segments / 2 - 45
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 5:
		var additional_rotation_ammount: int = 360 / segments / 2 - 22.5
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 6:
		var additional_rotation_ammount: int = 360 / segments / 2
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments == 7:
		var additional_rotation_ammount: int = 360 / segments / 2 + 15
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments >= 8:
		var additional_rotation_ammount: int = 360 / segments / 2 + 22.5
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))
	if segments >= 9:
		var additional_rotation_ammount: int = 360 / segments / 2 - 7.5
		rotate_labels.rotate(deg_to_rad(additional_rotation_ammount))

func draw_label(p1: Vector2, label: String):
	var new_label: Label = Label.new()
	new_label.text = label
	new_label.theme = load("res://Assets/Fonts/std_theme.tres") 
	new_label.set_anchors_preset(Control.PRESET_CENTER)
	
	if segments == 1:
		new_label.rotation = -1.75
		new_label.position = p1 - Vector2(0, 0)
	if segments == 2:
		new_label.rotation = 0
		new_label.position = p1 - Vector2(20, 60)
	if segments == 3:
		new_label.rotation = -1.5
		new_label.position = p1 - Vector2(-10, -10)
	if segments == 4:
		new_label.rotation = -1.75
		new_label.position = p1 - Vector2(-10, 0)
	if segments == 5:
		new_label.rotation = -1.75
		new_label.position = p1 - Vector2(-10, 0)
	if segments == 6:
		new_label.rotation = -1.75
		new_label.position = p1 - Vector2(-10, 10)
	if segments == 7:
		new_label.rotation = -2.25
		new_label.position = p1 - Vector2(-35, -10)
	if segments >= 8:
		new_label.rotation = -2.25
		new_label.position = p1 - Vector2(-25, -15)
	if segments >= 9:
		new_label.rotation = -3.25
		new_label.position = p1 - Vector2(-75, 10)
	
	rotate_labels.add_child(new_label)  

func track_selection_direction():
	var just_pressed_f_key = Input.is_action_just_pressed("f_key")
	var pressed_f_key = Input.is_action_pressed("f_key")
	var released_f_key = Input.is_action_just_released("f_key")
	if just_pressed_f_key:
		starting_point = get_global_mouse_position()
		#print(starting_point)
	if pressed_f_key:
		var ending_point = get_global_mouse_position()
		#print(starting_point)
		var difference: Vector2 = Vector2(ending_point.x, ending_point.y) - Vector2(starting_point.x, starting_point.y)
		var angle: float = atan2(difference.y, difference.x) / PI
		selection_direction = (angle + 1) * 180
		var single_segment_angle = 360 / segments
		target = selection_direction / single_segment_angle
	if released_f_key:
		selection = target
		selection_confirmed = true

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
		var center_x = (distance_from_center * 1.75) * cos(deg_to_rad(label_center_angle)) - 10
		var center_y = (distance_from_center * 1.75) * sin(deg_to_rad(label_center_angle)) + 40
		var end_x = distance_from_center * cos(deg_to_rad(segment_end_angle))
		var end_y = distance_from_center * sin(deg_to_rad(segment_end_angle))

		# Define points for the segment
		var p1: Vector2 = Vector2(start_x, start_y)
		var p2: Vector2 = Vector2(end_x, end_y)
		var extended_center_angle_point: Vector2 = Vector2(center_x, center_y)

		# Call the draw functions
		draw_arc_segment(p1, p2)
		draw_label(extended_center_angle_point, get_label_array()[segment - 1])

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
	rotate_radial.draw_arc(center, distance_from_center, start_angle, end_angle, 50, color, _popup_arc_width, antialiasing)

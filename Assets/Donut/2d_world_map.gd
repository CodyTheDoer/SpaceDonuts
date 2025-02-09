extends Node2D

@onready var popup_action_menu: Node2D = $popup_action_menu
@onready var target_area_map_layer: TileMapLayer = $TargetAreaMapLayer
@onready var remove_area_map_layer: TileMapLayer = $RemoveAreaMapLayer
@onready var wip_area_map_layer: TileMapLayer = $WIPAreaMapLayer
@onready var tilemap: TileMapLayer = %DonutTileMapLayer
@onready var player: Player = %Player
@onready var camera_2d: Camera2D = %Camera2D2

@export var ring_world: SpaceDonut
@export var player_coords: Vector2i
@export var camera_zoom: float = 1
@export var popup_options_labels: Resource

signal current_camera_zoom(camera_zoom: float)

var active_tile_map: Array[Array] = []
var ring_world_reference_map: Array[Array] = []
var player_interface_map: Array[Array] = []
var player_interface_mapped_targets = []
var remove_interface_mapped_targets = []

var player_tile_pos: Vector2i
var tile_size: int = 32
var world_x_max: int
var world_y_max: int
var display_radius: int = 25

var original_left_click_position: Vector2
var original_right_click_position: Vector2
var hover_left_click_position: Vector2
var hover_right_click_position: Vector2
var both_clicked: bool = false

var popup_target: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_ring_world_x_and_y()
	build_ringworld_map()
	init_active_tile_map()
	init_player_interface_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	current_camera_zoom.emit(camera_zoom)
	update_player_tile_pos()
	display_tiles_in_radius()
	montor_and_move_player_when_crossing_y_bounds()
	update_export_player_coords()
	monitor_player_click_and_drag_for_target_area()
	world_options_popup_menu()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if Vector2(camera_zoom, camera_zoom) < Vector2(2, 2):
				camera_zoom += 0.035
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if Vector2(camera_zoom, camera_zoom) > Vector2(1, 1):
				camera_zoom -= 0.035

# // --- _ready() --- //
func set_ring_world_x_and_y():
	var x_max = ring_world.ring_world_x_max
	var y_max = ring_world.ring_world_y_max
	world_x_max = x_max
	world_y_max = y_max

func build_ringworld_map():
	ring_world.build_if_new()
	ring_world_reference_map = ring_world.tile_map

func init_active_tile_map():
	for x in range(0 , world_x_max):
		active_tile_map.append([])
		for y in range(0 , world_y_max):
			active_tile_map[x].append(0)

func init_player_interface_map():
	for x in range(0 , world_x_max):
		player_interface_map.append([])
		for y in range(0 , world_y_max):
			player_interface_map[x].append(0)

# // --- _process() --- //
func world_options_popup_menu():
	var just_pressed_space = Input.is_action_just_pressed("space")
	var pressed_space = Input.is_action_pressed("space")
	var released_space = Input.is_action_just_released("space")
	var starting_point: Vector2
	if just_pressed_space:
		starting_point = get_global_mouse_position()
		popup_action_menu.position = get_global_mouse_position()
	if pressed_space:
		popup_action_menu.visible = true
		var ending_point = get_global_mouse_position()
		var difference: Vector2 = Vector2(ending_point.x, ending_point.y) - Vector2(starting_point.x, starting_point.y)
		var angle: float = atan2(difference.y, difference.x) / PI
		var selection_direction = (angle + 1) * 180
		var segments = len(popup_action_menu.options_array)
		var single_segment_angle = 360 / segments
		popup_target = (selection_direction / single_segment_angle)
		#print("Selection:", popup_target)
	if released_space:
		popup_action_menu.visible = false
	if popup_action_menu.selection_confirmed:
		popup_action_menu.selection = popup_target
		print("Selection Confirmed:", popup_action_menu.popup_soil_options_labels.get_label_array()[popup_action_menu.selection] )
		popup_action_menu.selection_confirmed = false

func update_player_tile_pos():
	var player_in_block = Vector2(player.position.x / tile_size as int, player.position.y / tile_size as int)
	player_tile_pos = player_in_block

func display_tiles_in_radius():
	var display_tiles = []
	var player_tile_pos = Vector2i(player.position / tile_size)  # Update tile size accordingly
	# Generate tiles within a radius
	for x in range(-display_radius, display_radius + 1):
		for y in range(-display_radius, display_radius + 1):
			if Vector2(x, y).length() <= display_radius:  # Check if within circle
				display_tiles.append(player_tile_pos + Vector2i(x, y))
	# Populate the tiles
	for tile in display_tiles:
		if tile.x > 0 and tile.y > 0:
			if tile.x < world_x_max and tile.y < world_y_max:
				tilemap.set_cell(tile, 1, ring_world_reference_map[tile.x][tile.y])
				active_tile_map[tile.x][tile.y] = 1
	# Prep to depopulate the tiles that aren't within the radius.
	var remove_tiles = []
	for x in range(0 , world_x_max):
		for y in range(0 , world_y_max):
			if active_tile_map[x][y] == 1:
				remove_tiles.append(Vector2i(x, y))
	# Filter to ensure we don't remove tiles withing sight radius
	for tile in display_tiles:
		remove_tiles.erase(tile)
	# Remove the tiles not within the radius
	for target in remove_tiles:
		tilemap.set_cell(target, -1)
		active_tile_map[target.x][target.y] = 0

func montor_and_move_player_when_crossing_y_bounds():
	if player_tile_pos.y > world_y_max:
		player.position.y = 0
	if player_tile_pos.y < 0:
		player.position.y = world_y_max * 32
	
func update_export_player_coords():
	player_coords = player.position

func monitor_player_click_and_drag_for_target_area():
	var input_right_click = Input.is_action_just_pressed("right_click")
	var input_left_click = Input.is_action_just_pressed("left_click")
	
	var pressed_right_click = Input.is_action_pressed("right_click")
	var pressed_left_click = Input.is_action_pressed("left_click")
	
	var release_right_click = Input.is_action_just_released("right_click")
	var release_left_click = Input.is_action_just_released("left_click")
	
	if input_right_click:
		original_right_click_position = target_area_map_layer.local_to_map(get_global_mouse_position())
		remove_area_map_layer.set_cell(original_right_click_position, 0, Vector2(3, 0))
	if pressed_right_click:
		hover_right_click_position = target_area_map_layer.local_to_map(get_global_mouse_position())
		animate_target_bounds_from_og_to_hover_remove(original_right_click_position, hover_right_click_position)
	if release_right_click and !pressed_left_click:
		remove_area_map_layer.clear()
		remove_range_from_player_interface_map(original_right_click_position, hover_right_click_position)
	
	if input_left_click:
		original_left_click_position = target_area_map_layer.local_to_map(get_global_mouse_position())
		target_area_map_layer.set_cell(original_left_click_position, 0, Vector2(3, 0))
	if pressed_left_click:
		if release_right_click:
			remove_interface_mapped_targets.append([original_right_click_position, hover_right_click_position])
			both_clicked = true
		hover_left_click_position = target_area_map_layer.local_to_map(get_global_mouse_position())
		animate_target_bounds_from_og_to_hover_target(original_left_click_position, hover_left_click_position)
	if release_left_click:
		append_range_to_player_interface_map(original_left_click_position, hover_left_click_position)
		if both_clicked == true:
			remove_area_map_layer.clear()
			remove_arrays_from_player_interface_map(remove_interface_mapped_targets)
			both_clicked = false
		target_area_map_layer.clear()

func remove_arrays_from_player_interface_map(array: Array):
	for target in array:
		var t0 = Vector2i(target[0].x, target[0].y)
		var t1 = Vector2i(target[1].x, target[1].y)
		remove_range_from_player_interface_map(t0, t1)
	remove_interface_mapped_targets = []

func animate_target_bounds_from_og_to_hover_target(p1: Vector2, p2: Vector2):
	var difference = p1 - p2
	target_area_map_layer.clear()
	
	# No movement, Original position
	if difference == Vector2(0, 0):
		target_area_map_layer.set_cell(p1, 0, Vector2(3, 0))
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				target_area_map_layer.set_cell(p1 - Vector2(0, y), 0, Vector2(3, 0))
		else:
			for y in -difference.y + 1:
				target_area_map_layer.set_cell(p1 + Vector2(0, y), 0, Vector2(3, 0))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				target_area_map_layer.set_cell(p1 - Vector2(x, 0), 0, Vector2(3, 0))
		else:
			for x in -difference.x + 1:
				target_area_map_layer.set_cell(p1 + Vector2(x, 0), 0, Vector2(3, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					target_area_map_layer.set_cell(p1 - Vector2(x, y), 0, Vector2(3, 0))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					target_area_map_layer.set_cell(p1 - Vector2(x, -y), 0, Vector2(3, 0))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					target_area_map_layer.set_cell(p1 - Vector2(-x, y), 0, Vector2(3, 0))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					target_area_map_layer.set_cell(p1 + Vector2(x, y), 0, Vector2(3, 0))

func animate_target_bounds_from_og_to_hover_remove(p1: Vector2, p2: Vector2):
	var difference = p1 - p2
	
	# No movement, Original position
	if difference == Vector2(0, 0):
		remove_area_map_layer.set_cell(p1, 0, Vector2(3, 0))
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				remove_area_map_layer.set_cell(p1 - Vector2(0, y), 0, Vector2(3, 0))
		else:
			for y in -difference.y + 1:
				remove_area_map_layer.set_cell(p1 + Vector2(0, y), 0, Vector2(3, 0))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				remove_area_map_layer.set_cell(p1 - Vector2(x, 0), 0, Vector2(3, 0))
		else:
			for x in -difference.x + 1:
				remove_area_map_layer.set_cell(p1 + Vector2(x, 0), 0, Vector2(3, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					remove_area_map_layer.set_cell(p1 - Vector2(x, y), 0, Vector2(3, 0))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					remove_area_map_layer.set_cell(p1 - Vector2(x, -y), 0, Vector2(3, 0))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					remove_area_map_layer.set_cell(p1 - Vector2(-x, y), 0, Vector2(3, 0))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					remove_area_map_layer.set_cell(p1 + Vector2(x, y), 0, Vector2(3, 0))

func append_range_to_player_interface_map(p1: Vector2, p2: Vector2):
	var difference = p1 - p2
	
	# No movement, Original position
	if p1.x == p2.x and p1.y == p2.y:
		player_interface_mapped_targets.append(p1)
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				player_interface_mapped_targets.append(p1 - Vector2(0, y))
		else:
			for y in -difference.y + 1:
				player_interface_mapped_targets.append(p1 + Vector2(0, y))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				player_interface_mapped_targets.append(p1 - Vector2(x, 0))
		else:
			for x in -difference.x + 1:
				player_interface_mapped_targets.append(p1 + Vector2(x, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					player_interface_mapped_targets.append(p1 - Vector2(x, y))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					player_interface_mapped_targets.append(p1 - Vector2(x, -y))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					player_interface_mapped_targets.append(p1 - Vector2(-x, y))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					player_interface_mapped_targets.append(p1 + Vector2(x, y))
	
	remove_player_interface_map_duplicates()
	wip_area_map_layer.set_cells_terrain_connect(player_interface_mapped_targets, 0, 0, false)

func remove_player_interface_map_duplicates():
	for target in player_interface_mapped_targets:
		var count = player_interface_mapped_targets.count(target)
		if count > 1:
			for _x in count - 1:
				player_interface_mapped_targets.erase(target)

func remove_remove_area_map_duplicates():
	for target in remove_interface_mapped_targets:
		var count = remove_interface_mapped_targets.count(target)
		if count > 1:
			for _x in count - 1:
				player_interface_mapped_targets.erase(target)

func remove_range_from_player_interface_map(p1: Vector2, p2: Vector2):
	#print(p1, p2)
	var difference = p1 - p2
	
	# No movement, Original position
	if p1.x == p2.x and p1.y == p2.y:
		player_interface_mapped_targets.erase(p1)
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				player_interface_mapped_targets.erase(p1 - Vector2(0, y))
		else:
			for y in -difference.y + 1:
				player_interface_mapped_targets.erase(p1 + Vector2(0, y))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				player_interface_mapped_targets.erase(p1 - Vector2(x, 0))
		else:
			for x in -difference.x + 1:
				player_interface_mapped_targets.erase(p1 + Vector2(x, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					player_interface_mapped_targets.erase(p1 - Vector2(x, y))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					player_interface_mapped_targets.erase(p1 - Vector2(x, -y))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					player_interface_mapped_targets.erase(p1 - Vector2(-x, y))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					player_interface_mapped_targets.erase(p1 + Vector2(x, y))
	
	wip_area_map_layer.clear()
	wip_area_map_layer.set_cells_terrain_connect(player_interface_mapped_targets, 0, 0, true)
	
	remove_remove_area_map_duplicates()

func _update_player_camera_zoom(value: float) -> void:
	camera_zoom = value

extends Control

@onready var popup_action_menu: Node2D = $popup_action_menu
@onready var interior_target_area_map_layer: TileMapLayer = $InteriorTargetAreaMapLayer
@onready var interior_remove_area_map_layer: TileMapLayer = $InteriorRemoveAreaMapLayer
@onready var interior_staged_area_map_layer: TileMapLayer = $InteriorStagedAreaMapLayer
@onready var interior_wip_area_map_layer: TileMapLayer = $InteriorWIPAreaMapLayer
@onready var interior_tilemap: TileMapLayer = %DonutInteriorTileMapLayer
@onready var player: Player = %Player
@onready var camera_2d: Camera2D = %Camera2D
@onready var plots_count: RichTextLabel = %PlotsCount
@onready var updates_queued: RichTextLabel = %UpdatesQueued

@export var ring_world: SpaceDonutInterior

@export var player_coords: Vector2i
@export var camera_zoom: float = 1
@export var popup_options_labels: Resource

signal current_camera_zoom(camera_zoom: float)

var active_tile_map: Array[Array] = []
@export var ring_world_interior_reference_map: Array[Array] = []
@export var player_interface_mapped_targets = []
var remove_interface_mapped_targets = []
@export var currently_tiling: bool = false
@export var tile_queue = []
@export var previous_tile_queue_size: int = 0
var clean_target_count = 0

var player_tile_pos: Vector2i
var tile_size: int = 32
var world_x_max: int
var world_y_max: int
var display_radius: int = 25

var left_click_pressed: bool = false
var right_click_pressed: bool = false
var original_left_click_position: Vector2
var original_right_click_position: Vector2
var hover_left_click_position: Vector2
var hover_right_click_position: Vector2
var both_clicked: bool = false
var starting_point: Vector2

var popup_target: int

# // --- potential_matches & tile_atlas_paths --- // 
# // --- These need to be updated together --- // 
var potential_matches = {
	"DIRT": 0,
	"FLOWERS": 1,
	"GRASS": 2,
	"ROCKY": 3,
	"TILLED": 4,
}

# // --- These need to be updated together ^^^ --- // 
var tile_atlas_paths = {
	0 : Vector2i(0, 0),
	1 : Vector2i(2, 0),
	2 : Vector2i(3, 0),
	3 : Vector2i(4, 0),
	4 : Vector2i(1, 0),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_ring_world_x_and_y()
	build_ringworld_map()
	init_active_tile_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	current_camera_zoom.emit(camera_zoom)
	update_player_tile_pos()
	display_tiles_in_radius()
	monitor_and_move_player_when_crossing_y_bounds()
	monitor_and_stop_player_when_crossing_x_bounds()
	update_export_player_coords()
	world_options_popup_menu()
	monitor_tile_queue()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if Vector2(camera_zoom, camera_zoom) < Vector2(2, 2):
				camera_zoom += 0.035
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if Vector2(camera_zoom, camera_zoom) > Vector2(1, 1):
				camera_zoom -= 0.035

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("right_click"):
			print("Input.is_action_just_pressed('right_click')")
			original_right_click_position = interior_target_area_map_layer.local_to_map(get_global_mouse_position())
			interior_remove_area_map_layer.set_cell(original_right_click_position, 0, Vector2(3, 0))
		if Input.is_action_pressed("right_click"):
			print("Input.is_action_pressed('right_click')")
			right_click_pressed = true
		if Input.is_action_just_released("right_click"):
			print("Input.is_action_just_released('right_click')")
			right_click_pressed = false
			if !left_click_pressed:
				print("!Input.is_action_pressed('left_click')")
				interior_remove_area_map_layer.clear()
				remove_range_from_player_interface_map(original_right_click_position, hover_right_click_position)
		if Input.is_action_just_pressed("left_click"):
			print("Input.is_action_just_pressed('left_click')")
			original_left_click_position = interior_target_area_map_layer.local_to_map(get_global_mouse_position())
			interior_target_area_map_layer.set_cell(original_left_click_position, 0, Vector2(3, 0))
		if Input.is_action_pressed("left_click"):
			print("Input.is_action_pressed('left_click')")
			left_click_pressed = true
		if Input.is_action_just_released("left_click"):
			left_click_pressed = false
			print("Input.is_action_just_released('left_click')")
			append_range_to_player_interface_map(original_left_click_position, hover_left_click_position)
			if both_clicked == true:
				interior_remove_area_map_layer.clear()
				remove_arrays_from_player_interface_map(remove_interface_mapped_targets)
				both_clicked = false
			interior_target_area_map_layer.clear()
	if right_click_pressed:
		hover_right_click_position = interior_target_area_map_layer.local_to_map(get_global_mouse_position())
		animate_target_bounds_from_og_to_hover_remove(original_right_click_position, hover_right_click_position)
	if left_click_pressed:
		if Input.is_action_just_released("right_click"):
			print("Input.is_action_just_released('right_click')")
			remove_interface_mapped_targets.append([original_right_click_position, hover_right_click_position])
			both_clicked = true
		hover_left_click_position = interior_target_area_map_layer.local_to_map(get_global_mouse_position())
		animate_target_bounds_from_og_to_hover_target(original_left_click_position, hover_left_click_position)

# // --- _ready() --- //
func set_ring_world_x_and_y():
	var x_max = ring_world.ring_world_x_max
	var y_max = ring_world.ring_world_y_max
	world_x_max = x_max
	world_y_max = y_max

func build_ringworld_map():
	ring_world.build_if_new()
	ring_world_interior_reference_map = ring_world.tile_map

func init_active_tile_map():
	for x in range(0 , world_x_max):
		active_tile_map.append([])
		for y in range(0 , world_y_max):
			active_tile_map[x].append(0)

# // --- _process() --- //
func world_options_popup_menu():
	var just_pressed_space = Input.is_action_just_pressed("space")
	var pressed_space = Input.is_action_pressed("space")
	var released_space = Input.is_action_just_released("space")
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
	if released_space:
		popup_action_menu.visible = false
	if popup_action_menu.selection_confirmed:
		popup_action_menu.selection = popup_target
		randomize()
		var local_target_map = player_interface_mapped_targets.duplicate()
		local_target_map.shuffle()
		interior_wip_area_map_layer.clear()
		player_interface_mapped_targets.clear()
		if await init_action_from_selection(
			popup_action_menu.get_label_array()[popup_action_menu.selection], 
			local_target_map,
		) == false && popup_action_menu.get_label_array()[popup_action_menu.selection] != "CANCEL":
			tile_queue.append([popup_action_menu.get_label_array()[popup_action_menu.selection], local_target_map])
		popup_action_menu.selection_confirmed = false

func remove_targets_outside_of_world_coords(array: Array):
	for target in array:
		if target.x >= world_x_max:
			array.erase(target)
		if target.y > world_y_max:
			array.erase(target)
	return array

func init_action_from_selection(selection: String, target_array: Array):
	print(selection, ", currently_tiling: ", currently_tiling)
	var clean_target_array = remove_targets_outside_of_world_coords(target_array.duplicate())
	interior_wip_area_map_layer.set_cells_terrain_connect(clean_target_array, 0, 0, true)
	if currently_tiling:
		return false
	if !currently_tiling:
		currently_tiling = true
		match selection:
			"CANCEL":
				pass
			"TILL":
				for target in clean_target_array:
					await get_tree().create_timer(0.00125).timeout 
					update_tile_to(target, "TILLED")
					clean_target_count += 1
					if plots_count != null:
						plots_count.text = str((clean_target_count / float(len(clean_target_array))) * 100).pad_decimals(2)
			"GRASS":
				for target in clean_target_array:
					await get_tree().create_timer(0.00125).timeout 
					update_tile_to(target, "GRASS")
					clean_target_count += 1
					if plots_count != null:
						plots_count.text = str((clean_target_count / float(len(clean_target_array))) * 100).pad_decimals(2)
			"DIRT":
				for target in clean_target_array:
					await get_tree().create_timer(0.00125).timeout 
					update_tile_to(target, "DIRT")
					clean_target_count += 1
					if plots_count != null:
						plots_count.text = str((clean_target_count / float(len(clean_target_array))) * 100).pad_decimals(2)
			"FLOWERS":
				for target in clean_target_array:
					await get_tree().create_timer(0.00125).timeout 
					update_tile_to(target, "FLOWERS")
					clean_target_count += 1
					if plots_count != null:
						plots_count.text = str((clean_target_count / float(len(clean_target_array))) * 100).pad_decimals(2)
			"ROCK":
				for target in clean_target_array:
					await get_tree().create_timer(0.00125).timeout 
					update_tile_to(target, "ROCKY")
					clean_target_count += 1
					if plots_count != null:
						plots_count.text = str((clean_target_count / float(len(clean_target_array))) * 100).pad_decimals(2)
		currently_tiling = false
		interior_wip_area_map_layer.clear()
		clean_target_count = 0
		if plots_count != null:
			plots_count.text = "Ready..."
		return true

func monitor_tile_queue():
	if len(tile_queue) != previous_tile_queue_size:
		if updates_queued != null:
			updates_queued.text = str(len(tile_queue))
		previous_tile_queue_size = len(tile_queue)
		interior_staged_area_map_layer.clear()
		for tileset in tile_queue:
			interior_staged_area_map_layer.set_cells_terrain_connect(tileset[1], 0, 0, false)
	
	if len(tile_queue) > 0 && currently_tiling == false:
		await init_action_from_selection(tile_queue[0][0], tile_queue[0][1])
		tile_queue.remove_at(0)

func update_tile_to(location: Vector2i, new_tile: String):
	if location.x >= world_x_max:
		return
	if location.y > world_y_max:
		return
	ring_world_interior_reference_map[location.x][location.y] = tile_atlas_paths[potential_matches[new_tile]]

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
				interior_tilemap.set_cell(tile, 1, ring_world_interior_reference_map[tile.x][tile.y])
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
		interior_tilemap.set_cell(target, -1)
		active_tile_map[target.x][target.y] = 0

func monitor_and_move_player_when_crossing_y_bounds():
	if player_tile_pos.y > world_y_max:
		player.position.y = 1 * 32
	if player_tile_pos.y < 0:
		player.position.y = (world_y_max * 32) - (1 * 32)

func monitor_and_stop_player_when_crossing_x_bounds():
	if player_tile_pos.x > world_x_max - 1:
		player.position.x = world_x_max * 32
	if player_tile_pos.x < 1:
		player.position.x = 1 * 32

func update_export_player_coords():
	player_coords = player.position

func remove_arrays_from_player_interface_map(array: Array):
	for target in array:
		var t0 = Vector2i(target[0].x, target[0].y)
		var t1 = Vector2i(target[1].x, target[1].y)
		remove_range_from_player_interface_map(t0, t1)
	remove_interface_mapped_targets = []

func animate_target_bounds_from_og_to_hover_target(p1: Vector2, p2: Vector2):
	var difference = p1 - p2
	if difference.x * difference.y > 15625 or difference.x * difference.y < -15625:
		return
	interior_target_area_map_layer.clear()
	
	# No movement, Original position
	if difference == Vector2(0, 0):
		interior_target_area_map_layer.set_cell(p1, 0, Vector2(3, 0))
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				interior_target_area_map_layer.set_cell(p1 - Vector2(0, y), 0, Vector2(3, 0))
		else:
			for y in -difference.y + 1:
				interior_target_area_map_layer.set_cell(p1 + Vector2(0, y), 0, Vector2(3, 0))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				interior_target_area_map_layer.set_cell(p1 - Vector2(x, 0), 0, Vector2(3, 0))
		else:
			for x in -difference.x + 1:
				interior_target_area_map_layer.set_cell(p1 + Vector2(x, 0), 0, Vector2(3, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					interior_target_area_map_layer.set_cell(p1 - Vector2(x, y), 0, Vector2(3, 0))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					interior_target_area_map_layer.set_cell(p1 - Vector2(x, -y), 0, Vector2(3, 0))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					interior_target_area_map_layer.set_cell(p1 - Vector2(-x, y), 0, Vector2(3, 0))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					interior_target_area_map_layer.set_cell(p1 + Vector2(x, y), 0, Vector2(3, 0))

func animate_target_bounds_from_og_to_hover_remove(p1: Vector2, p2: Vector2):
	var difference = p1 - p2
	
	# No movement, Original position
	if difference == Vector2(0, 0):
		interior_remove_area_map_layer.set_cell(p1, 0, Vector2(3, 0))
	
	# Single wide Column, Y movement 
	if difference.x == 0 and difference.y != 0:
		if difference.y > 0:
			for y in difference.y + 1:
				interior_remove_area_map_layer.set_cell(p1 - Vector2(0, y), 0, Vector2(3, 0))
		else:
			for y in -difference.y + 1:
				interior_remove_area_map_layer.set_cell(p1 + Vector2(0, y), 0, Vector2(3, 0))
	
	# Single wide Row, X movement 
	if difference.x != 0 and difference.y == 0:
		if difference.x > 0:
			for x in difference.x + 1:
				interior_remove_area_map_layer.set_cell(p1 - Vector2(x, 0), 0, Vector2(3, 0))
		else:
			for x in -difference.x + 1:
				interior_remove_area_map_layer.set_cell(p1 + Vector2(x, 0), 0, Vector2(3, 0))
	
	# Expanded in two directions, X and Y movement
	if difference != Vector2(0, 0):
		# Upper Left
		if difference > Vector2(0, 0):
			for x in difference.x + 1:
				for y in difference.y + 1:
					interior_remove_area_map_layer.set_cell(p1 - Vector2(x, y), 0, Vector2(3, 0))
		# Bottom Left
		if difference.x > 0 and difference.y < 0:
			for x in difference.x + 1:
				for y in -difference.y + 1:
					interior_remove_area_map_layer.set_cell(p1 - Vector2(x, -y), 0, Vector2(3, 0))
		# Upper Right
		if difference.x < 0 and difference.y > 0:
			for x in -difference.x + 1:
				for y in difference.y + 1:
					interior_remove_area_map_layer.set_cell(p1 - Vector2(-x, y), 0, Vector2(3, 0))
		# Bottom Right
		else:
			for x in -difference.x + 1:
				for y in -difference.y + 1:
					interior_remove_area_map_layer.set_cell(p1 + Vector2(x, y), 0, Vector2(3, 0))

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
	interior_wip_area_map_layer.set_cells_terrain_connect(player_interface_mapped_targets, 0, 0, false)

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
	
	interior_wip_area_map_layer.clear()
	interior_wip_area_map_layer.set_cells_terrain_connect(player_interface_mapped_targets, 0, 0, true)
	
	remove_remove_area_map_duplicates()

func _update_player_camera_zoom(value: float) -> void:
	camera_zoom = value

extends Camera3D

var player_location: Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for node in get_tree().get_nodes_in_group("PlayerLocationLightIndicator"):
		player_location = node.global_position
	var control_position = get_viewport().get_camera_3d().unproject_position(player_location)

	for node in get_tree().get_nodes_in_group("UILabelOrbitCamAvatarLocation"):
		node.position = control_position

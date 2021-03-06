extends Spatial

func _ready() -> void:
	# Reset camera
	reset_camera()
	
	# Show HUD
	HUD.visible = true

func _physics_process(delta: float) -> void:
	if not GameManager.is_interrupted:
		# Make camera look at active player
		reset_camera()

func reset_camera() -> void:
	# Check if player exists in tree
	# This is also handling issue player not ready in the tree
	# at the beginning of the game
	var players = get_tree().get_nodes_in_group("player")
	if players:
		# Get first player in group
		var player_location = players[0].global_transform.origin
		
		# Get active camera
		var camera = get_node("/root").get_camera()
		
		# Point camera looking to the first player in group
		camera.translation.x = player_location.x
		camera.translation.z = player_location.z + 50
		camera.translation.y = player_location.y + 55
		camera.look_at(player_location, Vector3(0, 1, 0))
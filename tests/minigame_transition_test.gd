extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func frames(count: int = 4) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func run() -> void:
	var park = load("res://map/карта1.tscn").instantiate()
	root.add_child(park)
	current_scene = park
	await frames()
	var player = park.get_node("карта1/player")
	var camera = player.get_node("Camera2D")
	var zone = park.get_node("Area2D")
	player.global_position = zone.get_node("CollisionShape2D2").global_position
	await frames()
	assert(zone.player_inside, "Player must be detected in entrance")
	assert(zone.get_node("Prompt").visible, "Entrance prompt must appear")
	var original_transform = player.transform
	var original_scale = player.global_scale
	var original_camera_limits = Vector4i(camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom)
	var original_parent = player.get_parent()
	var original_sprite_frames = player.get_node("AnimatedSprite2D").sprite_frames
	for attempt in range(2):
		var accept = InputEventAction.new()
		accept.action = "ui_accept"
		accept.pressed = true
		Input.parse_input_event(accept)
		await frames()
		accept.pressed = false
		Input.parse_input_event(accept)
		var arena = root.get_node("Minigame")
		assert(player.get_parent() == arena, "Same player must be transferred")
		assert(not park.visible and park.process_mode == Node.PROCESS_MODE_DISABLED)
		assert(player.global_scale.is_equal_approx(original_scale), "World scale must be preserved")
		assert(player.get_node("AnimatedSprite2D").sprite_frames == original_sprite_frames)
		assert(player.get_node("Camera2D") == camera and camera.zoom == Vector2(2, 2))
		assert(arena.get_node("Ground").get_used_cells().size() == 1000)
		var start = player.global_position
		Input.action_press("ui_right")
		await frames(10)
		Input.action_release("ui_right")
		await frames()
		assert(player.global_position.x > start.x, "Movement must work in minigame")
		player.global_position = Vector2(630, 200)
		Input.action_press("ui_right")
		await frames(25)
		Input.action_release("ui_right")
		assert(player.global_position.x < 640, "Arena walls must block player")
		var cancel = InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		Input.parse_input_event(cancel)
		await frames()
		cancel.pressed = false
		Input.parse_input_event(cancel)
		assert(player.get_parent() == original_parent)
		assert(player.transform.is_equal_approx(original_transform), "Return position and scale must be restored")
		assert(park.visible and park.process_mode == Node.PROCESS_MODE_INHERIT)
		assert(Vector4i(camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom) == original_camera_limits)
		assert(not root.has_node("Minigame"), "Arena must be freed")
		assert(zone.player_inside and not zone._opening, "Must allow another visit")
	print("PASS: two entrance/exit cycles, same player/appearance/scale/camera, movement, walls and park restoration")
	quit()

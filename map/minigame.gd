# Отдельная площадка. Парк сохраняется, чтобы вернуться без потери состояния.
extends Node2D

signal returned_to_park

var _player: CharacterBody2D
var _park: Node2D
var _original_parent: Node
var _original_transform: Transform2D
var _park_process_mode: int
var _park_visible: bool
var _camera: Camera2D
var _camera_limits: Vector4i
var _returning := false


func _ready() -> void:
	for x in range(40):
		for y in range(25):
			$Ground.set_cell(Vector2i(x, y), 0, Vector2i(1, 2))


func enter_from_park(player: CharacterBody2D, park: Node2D) -> void:
	_player = player
	_park = park
	_original_parent = player.get_parent()
	_original_transform = player.transform
	_park_process_mode = park.process_mode
	_park_visible = park.visible
	_camera = player.get_node("Camera2D") as Camera2D
	_camera_limits = Vector4i(_camera.limit_left, _camera.limit_top, _camera.limit_right, _camera.limit_bottom)
	# Сохраняем мировой масштаб, включая масштаб родителя на карте.
	player.reparent(self, true)
	player.global_position = $Spawn.global_position
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()
	_camera.limit_left = -10000000
	_camera.limit_top = -10000000
	_camera.limit_right = 10000000
	_camera.limit_bottom = 10000000
	_camera.reset_smoothing()
	_camera.force_update_scroll()
	park.hide()
	park.process_mode = Node.PROCESS_MODE_DISABLED


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_player) and not _returning and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_returning = true
		return_to_park.call_deferred()


func return_to_park() -> void:
	if not is_instance_valid(_player) or not is_instance_valid(_park):
		return
	_player.reparent(_original_parent, false)
	_player.transform = _original_transform
	_player.velocity = Vector2.ZERO
	_player.reset_physics_interpolation()
	_camera.limit_left = _camera_limits.x
	_camera.limit_top = _camera_limits.y
	_camera.limit_right = _camera_limits.z
	_camera.limit_bottom = _camera_limits.w
	_park.visible = _park_visible
	_park.process_mode = _park_process_mode
	_camera.reset_smoothing()
	_camera.force_update_scroll()
	returned_to_park.emit()
	queue_free()

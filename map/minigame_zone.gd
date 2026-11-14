# Вход на площадку мини-игры. Сам персонаж переносится вместе с камерой.
extends Area2D

@export var minigame_scene: PackedScene

@onready var prompt: Label = $Prompt
var player_inside := false
var _player: CharacterBody2D
var _opening := false


func _ready() -> void:
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		_player = body
		player_inside = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		player_inside = false
		prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not _opening and event.is_action_pressed("ui_accept") and not event.is_echo():
		get_viewport().set_input_as_handled()
		start_minigame()


func start_minigame() -> void:
	if _opening or not is_instance_valid(_player):
		return
	if not minigame_scene:
		push_warning("Мини-игра не назначена в инспекторе!")
		return
	_opening = true
	# Не меняем дерево и физические тела внутри обработки ввода/сигналов физики.
	_open_minigame.call_deferred(_player)


func _open_minigame(player: CharacterBody2D) -> void:
	if not is_instance_valid(player):
		_opening = false
		return
	var minigame := minigame_scene.instantiate()
	if not minigame.has_method("enter_from_park") or not minigame.has_signal("returned_to_park"):
		push_error("Сцена мини-игры должна поддерживать вход и возврат в парк.")
		minigame.free()
		_opening = false
		return
	minigame.connect("returned_to_park", _on_returned_to_park)
	get_tree().root.add_child(minigame)
	minigame.call("enter_from_park", player, get_tree().current_scene)


func _on_returned_to_park() -> void:
	_opening = false

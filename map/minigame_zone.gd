# Зона мини-игры: игрок подошёл, появилась подсказка, нажал Enter или пробел, открылась сцена мини-игры.
# Сцена: Area2D (этот скрипт) -> CollisionShape2D и Label с именем Prompt.
# Игрока добавьте в группу "player": вкладка Node -> Groups.
extends Area2D

@export var minigame_scene: PackedScene  # в инспекторе укажите сцену мини-игры

@onready var prompt: Label = $Prompt

var player_inside := false


func _ready() -> void:
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		prompt.hide()


func _input(event: InputEvent) -> void:
	# Используем _input вместо _unhandled_input для надёжности
	if player_inside and minigame_scene and event.is_action_pressed("ui_accept"):
		start_minigame()


func start_minigame() -> void:
	if not minigame_scene:
		push_warning("Мини-игра не назначена в инспекторе!")
		return
	
	# Опционально: можно добавить звук или эффект перед переходом
	get_tree().change_scene_to_packed(minigame_scene)

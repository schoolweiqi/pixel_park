extends CharacterBody2D

@export var speed: float = 80.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.DOWN  # запоминаем последнее направление


func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = input_dir * speed
	move_and_slide()
	
	update_animation(input_dir)


func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		last_direction = direction
		
		# Движение
		if abs(direction.x) > abs(direction.y):
			# Идём вбок
			anim.play("front")
			anim.flip_h = direction.x < 0
		elif direction.y < 0:
			anim.play("up")
			anim.flip_h = false
		else:
			anim.play("down")
			anim.flip_h = false
	else:
		# Стоим
		if abs(last_direction.x) > abs(last_direction.y):
			anim.play("i_front")
			anim.flip_h = last_direction.x < 0
		elif last_direction.y < 0:
			anim.play("i_up")
			anim.flip_h = false
		else:
			anim.play("i_down")
			anim.flip_h = false

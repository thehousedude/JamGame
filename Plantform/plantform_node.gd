# PlatformController.gd
@tool
extends Node2D

# 移动控制
@export var allow_player_move: bool = false
@export var move_speed: float = 100.0

# 旋转控制
@export var allow_player_rotate: bool = false
@export var rotation_speed: float = 90.0
@export var rotation_range: Vector2 = Vector2(-45, 45)

# Area2D 形状控制
@export var collision_shape: Shape2D:
	set(value):
		collision_shape = value
		_update_area_shape()

# Area2D 位置控制
@export var area_position: Vector2:
	set(value):
		area_position = value
		_update_area_position()

@onready var platform: CharacterBody2D = $Platform
@onready var area2d: Area2D = $Area2D

func _ready():
	if not Engine.is_editor_hint():
		_update_area_shape()
		_update_area_position()

func _update_area_shape():
	if area2d and area2d.has_node("CollisionShape2D"):
		area2d.get_node("CollisionShape2D").shape = collision_shape

func _update_area_position():
	if area2d:
		area2d.position = area_position

func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if allow_player_move or allow_player_rotate:
		_handle_player_input(delta)

func _handle_player_input(delta):
	if allow_player_move:
		var move_direction = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			move_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			move_direction.y += 1
		if Input.is_action_pressed("ui_left"):
			move_direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			move_direction.x += 1

		if move_direction != Vector2.ZERO:
			move_direction = move_direction.normalized()
			platform.velocity = move_direction * move_speed
		else:
			platform.velocity = Vector2.ZERO

	if allow_player_rotate:
		var rotation_delta = 0.0
		if Input.is_action_pressed("ui_left"):
			rotation_delta -= rotation_speed * delta
		if Input.is_action_pressed("ui_right"):
			rotation_delta += rotation_speed * delta

		if rotation_delta != 0.0:
			var new_rotation = platform.rotation_degrees + rotation_delta
			platform.rotation_degrees = clamp(new_rotation, rotation_range.x, rotation_range.y)

extends StaticBody2D

@export var can_drag_x: bool = true
@export var can_drag_y: bool = true
@export var x_move_range: Vector2 = Vector2(-50, 50)
@export var y_move_range: Vector2 = Vector2(-50, 50)
@export var bounce_force: float = 500.0

@onready var arrow_marker = $ArrowMarker
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var bounce_area = $BounceArea

var is_dragging = false
var drag_start_pos = Vector2.ZERO
var original_position = Vector2.ZERO


func _trigger_bounce(body:Node2D):
	if !body is Player:return
	body.falling_distance=0.0
	# 播放弹簧动画
	animated_sprite.play("bounce")
	
	# 计算弹跳方向
	var bounce_direction = Vector2.UP.rotated(rotation)
	
	# 根据拖动距离计算实际弹跳力
	var actual_force = bounce_force
	
	if body.has_method("bounce") and body is Player:
		# 将力沿计算出的方向施加
		var force_vector = bounce_direction * actual_force
		
		body.bounce(force_vector)
	


func _on_animated_sprite_2d_animation_finished():
	animated_sprite.play("idle")

extends CharacterBody2D
class_name Player

@export var SPEED = 80.0
@export var JUMP_VELOCITY = -200.0
@export var FALL_GRAVITY = 600.0  # 坠落重力
@export var JUMP_GRAVITY = 400.0  # 跳跃重力

# 状态机
enum PlayerState {NORMAL, INTERACTING}
var current_state = PlayerState.NORMAL

# 重力方向
enum GravityDirection {DOWN, UP}
var gravity_direction = GravityDirection.DOWN
var can_flip_gravity = true  # 是否可以进行重力反转检测
signal gravity_change
# 交互状态标志
var is_interacting = false

# 下落检测相关
var falling_distance = 0.0
var is_falling = false
const BOUNCE_THRESHOLD = 80  # 5格 = 16 * 5 = 80
const GRAVITY_FLIP_THRESHOLD = 112  # 7格 = 16 * 7 = 112
const BOUNCE_FORCE = Vector2(0, -250)  # 向上弹跳的力度

#反重力状态
var is_antiG = false

# 动画播放器
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D2

signal player_died

func _ready():
	pass

func _physics_process(delta):
	# 重力处理
	var gravity_factor = 1 if gravity_direction == GravityDirection.DOWN else -1
	
	# 跟踪下落距离
	update_falling(delta, gravity_factor)
	
	# 跳跃处理
	if Input.is_action_just_pressed("jump") and is_grounded() and not is_interacting:
		velocity.y = JUMP_VELOCITY * gravity_factor
	
	# 水平移动
	var direction = Input.get_axis("move_left", "move_right")
	if not is_interacting:
		velocity.x = direction * SPEED
		if direction != 0:
			sprite.scale.x = abs(sprite.scale.x) * direction
	
	# 交互状态处理
	if is_interacting:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# 更新动画
	update_animation()

func update_falling(delta, gravity_factor):
	if !is_grounded():
		# 根据垂直速度决定使用哪种重力
		var gravity = FALL_GRAVITY if is_falling_down() else JUMP_GRAVITY
		velocity.y += gravity * gravity_factor * delta
		
		if (gravity_direction == GravityDirection.DOWN and velocity.y > 0) or \
		   (gravity_direction == GravityDirection.UP and velocity.y < 0):
			is_falling = true
			falling_distance += abs(velocity.y * delta)
	else:
		# 着地时检查是否需要反转重力
		if is_falling and falling_distance >= GRAVITY_FLIP_THRESHOLD and can_flip_gravity:
			flip_gravity()
			can_flip_gravity = false  # 反转后禁用重力反转检测
		# 检查是否需要弹跳
		elif is_falling and falling_distance >= BOUNCE_THRESHOLD and can_flip_gravity:
			var bounce_force = BOUNCE_FORCE
			if gravity_direction == GravityDirection.UP:
				bounce_force = Vector2(0, abs(BOUNCE_FORCE.y))
			bounce(bounce_force)
		else:
			# 正常着地，且不是刚反转重力后的第一次着地
			if !is_falling:
				can_flip_gravity = true  # 启用重力反转检测
		
		is_falling = false
		falling_distance = 0

func is_falling_down() -> bool:
	if gravity_direction == GravityDirection.DOWN:
		return velocity.y > 0
	else:
		return velocity.y < 0

func flip_gravity():
	gravity_direction = GravityDirection.UP if gravity_direction == GravityDirection.DOWN else GravityDirection.DOWN
	sprite.scale.y = -sprite.scale.y
	falling_distance = 0  # 重置下落距离
	is_antiG = !is_antiG #设置反重力状态 用于动画
	gravity_change.emit()

func bounce(force: Vector2):
	velocity = force

func start_interacting():
	is_interacting = true
	current_state = PlayerState.INTERACTING
	#animation_player.play("interact")

func end_interacting():
	is_interacting = false
	current_state = PlayerState.NORMAL
	animation_player.play("idle")

func update_animation():
	if is_grounded():
		if abs(velocity.x) > 0:
			animation_player.play("walk")
		else:
			if is_antiG == false:
				animation_player.play("idle")
			else:
				animation_player.play("anti_gravity")
	else:
		if velocity.y * (1 if gravity_direction == GravityDirection.DOWN else -1) < 0:
			animation_player.play("jump")
		else:
			animation_player.play("fell")

func die():
	emit_signal("player_died")
	animation_player.play("death")
	# 禁用所有输入控制
	set_physics_process(false)
	# 可选：禁用碰撞
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _on_hazard_detector_area_entered(area: Area2D):
	if area.is_in_group("hazards"):
		die()

func _on_interactable_area_entered(_area):
	if _area.is_in_group("interactables"):
		start_interacting()

func _on_interactable_area_exited(_area):
	if _area.is_in_group("interactables"):
		end_interacting()

func is_grounded() -> bool:
	return (gravity_direction == GravityDirection.DOWN and is_on_floor()) or \
		   (gravity_direction == GravityDirection.UP and is_on_ceiling())

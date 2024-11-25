extends Camera2D
class_name GameCamera

@export var the_offset: Vector2 = Vector2.ZERO
@export var def_zoom := Vector2(4, 4):
	set(value):
		def_zoom = value
		zoom = value

@export var follow_speed := 10.0
@export var target_path: NodePath
@export var target_group: String = "players"

var follow_target: Node2D = null

@onready var viewport_size: Vector2 = get_viewport().size

func _ready():
	zoom = def_zoom
	GameState.game_camera=self
	if not target_path.is_empty():
		follow_target = get_node(target_path)
	elif not target_group.is_empty():
		var targets = get_tree().get_nodes_in_group(target_group)
		if not targets.is_empty():
			follow_target = targets[0]

var camera_velocity = Vector2.ZERO
const SMOOTHING = 0.25  # 平滑系数
const DAMPING = 0.85    # 阻尼系数，控制"重量感"

func _physics_process(delta):
	if follow_target:
		if follow_target != null:
			var camera_offset = the_offset
			# 计算目标位置和当前位置的差值
			var target_pos = follow_target.global_position + camera_offset
			var distance = target_pos - global_position
			
			# 使用弹性移动计算新的速度
			camera_velocity = camera_velocity.lerp(distance * follow_speed, SMOOTHING)
			camera_velocity *= DAMPING  # 应用阻尼
			
			# 应用移动
			global_position += camera_velocity * delta
			position = position.round()




var current_tween: Tween = null

func shake(duration: float, strength: float, frequency: float = 10):
	# 如果当前有正在进行的抖动，先停止它
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	var start_pos = offset
	current_tween = create_tween()
	
	for i in range(frequency):
		var rand_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		current_tween.tween_property(self, "offset", start_pos + rand_offset, duration / (frequency * 2))
		current_tween.tween_property(self, "offset", start_pos, duration / (frequency * 2))
	
	# 最后确保回到原始位置
	current_tween.tween_property(self, "offset", Vector2.ZERO, 0.1)
	
	await current_tween.finished
	current_tween = null

func move_to(pos: Vector2, duration: float = 0.5, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT):
	var tween = create_tween()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	tween.tween_property(self, "global_position", pos, duration)

func zoom_to(new_zoom: Vector2, duration: float = 0.5, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT):
	var tween = create_tween()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	tween.tween_property(self, "zoom", new_zoom, duration)

func set_follow_target(target: Node2D):
	follow_target = target

func set_follow_position(pos: Vector2):
	follow_target = null
	move_to(pos)

func hitstop(duration: float):
	Engine.time_scale = 0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1

func hit(_scale: Vector2, _offset: Vector2):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "offset", Vector2.ZERO, 0.12).from(_offset)
	tween.tween_property(self, "zoom", def_zoom, 0.12).from(_scale)


func reset_position():
	global_position = follow_target.global_position + the_offset

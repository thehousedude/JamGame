# Platform.gd
extends CharacterBody2D

var last_position: Vector2
var last_rotation: float

func _ready():
	last_position = global_position
	last_rotation = global_rotation

func _physics_process(delta):
	if get_parent().allow_player_move:
		# 检查移动后的位置是否会超出Area2D范围
		var potential_position = global_position + velocity * delta
		if not _is_point_in_area(potential_position):
			velocity = Vector2.ZERO
	
	# 移动平台
	move_and_slide()
	
	# 处理与其他物体（如玩家）的碰撞
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		
		if collider is CharacterBody2D and collider.has_method("bounce"):
			var collision_normal = col.get_normal()
			
			# 检查碰撞是否发生在平台上方
			if collision_normal.dot(Vector2.UP) < -0.7:
				# 传递平台的速度给站在上面的物体
				collider.velocity.x = velocity.x
				if velocity.y < 0:
					collider.velocity.y = velocity.y
				
				# 如果平台在旋转，添加切向速度
				if rotation != last_rotation:
					var angular_velocity = (rotation - last_rotation) / delta
					var radius = collider.global_position - global_position
					var tangential_velocity = Vector2(-radius.y, radius.x) * angular_velocity
					collider.velocity += tangential_velocity
	
	# 更新上一帧的状态
	last_position = global_position
	last_rotation = rotation

func _is_point_in_area(point: Vector2) -> bool:
	var area = get_parent().get_node("Area2D")
	var shape = area.get_node("CollisionShape2D").shape
	
	# 将全局坐标转换为相对于Area2D的本地坐标
	var local_point = area.to_local(point)
	
	# 根据形状类型进行检查
	if shape is RectangleShape2D:
		return abs(local_point.x) <= shape.extents.x and abs(local_point.y) <= shape.extents.y
	elif shape is CircleShape2D:
		return local_point.length() <= shape.radius
	
	return false

func bounce(force: float):
	velocity.y = -force

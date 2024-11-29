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
		
		last_position = global_position
		move_and_slide()
		
		if velocity.y == 0 and global_position.y != last_position.y:
			global_position.y = last_position.y
		
		# 检查碰撞并处理
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is CharacterBody2D:
				var normal = collision.get_normal()
				
				# 处理垂直方向的碰撞
				if (velocity!=Vector2.ZERO) and normal.y > 0:  # 向上移动且碰到物体
					velocity.y = 0
					velocity.x = 0
					global_position.y = last_position.y
					global_position.x = last_position.x
				elif (velocity!=Vector2.ZERO) and normal.y < 0:  # 向下移动且碰到物体
					velocity.y = 0
					velocity.x = 0
					global_position.y = last_position.y
					global_position.x = last_position.x
				
				# 处理平台效果
				if normal.dot(Vector2.DOWN) < -0.7:  # 物体在平台上方
					var moved_position = global_position - last_position
					collider.position += moved_position
					
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

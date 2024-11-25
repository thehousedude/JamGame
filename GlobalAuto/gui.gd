extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect


func get_pixel_position_on_screen(world_position: Vector2) -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		push_error("No active Camera2D found in the viewport")
		return Vector2.ZERO
	
	var viewport_rect = get_viewport().get_visible_rect()
	var viewport_center = viewport_rect.size / 2
	var camera_center = camera.get_screen_center_position()
	var camera_zoom = camera.zoom
	
	return (world_position - camera_center) * camera_zoom + viewport_center


func fade(to_color: Color, duration: float, from_color = null) -> void:
	color_rect.visible = true
	var tween = create_tween()
	
	if from_color == null:
		from_color = color_rect.modulate
	else:
		color_rect.modulate = from_color
	
	tween.tween_property(color_rect, "modulate", to_color, duration)
	await tween.finished
	
	if to_color.a == 0:
		color_rect.visible = false

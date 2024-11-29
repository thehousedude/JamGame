extends RayCast2D

@onready var line_2d: Line2D = $Line2D


@export var is_casting:bool=true:
	set(value):
		is_casting=value
		set_physics_process(is_casting)

func _ready() -> void:
	set_physics_process(is_casting)

func _physics_process(delta: float) -> void:
	var raycast_point=target_position
	force_raycast_update()
	
	if is_colliding():
		raycast_point=to_local(get_collision_point())
	line_2d.points[1] = raycast_point


func _appear():
	var tween=create_tween()
	tween.tween_property(line_2d,"width",8,.2)
	await tween.finished

func _disappear():
	var tween=create_tween()
	tween.tween_property(line_2d,"width",0,.2)
	await tween.finished

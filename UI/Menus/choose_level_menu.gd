extends Control

var level_chosed=false

@onready var grid_container: GridContainer = $LevelS/GridContainer

func _ready() -> void:
	if grid_container.get_child_count()!=0:
		for child in grid_container.get_children():
			child.level_chosed.connect(_on_level_button_level_chosed)

func _on_level_button_level_chosed(关卡路径: Variant) -> void:
	if level_chosed:return
	level_chosed=true
	await Gui.fade(Color(0, 0, 0, 1), .5)  # 淡入到黑色
	# 2. 切换场景
	var new_scene_path = 关卡路径
	var error = get_tree().change_scene_to_file(new_scene_path)
	if error != OK:
		push_error("Failed to change scene to " + new_scene_path)
		return

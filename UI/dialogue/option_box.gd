# OptionBox.gd
extends MarginContainer

signal option_selected(option_index)

@onready var option_container = $VBoxContainer

@onready var option_scene = preload("res://UI/dialogue/OptionButton.tscn")

func setup_options(options):
	for i in range(options.size()):
		var option = option_scene.instantiate()
		option.text = options[i][0]
		print(_on_option_pressed.bind(i))
		option.connect("_be_pressed", _on_option_selected.bind(i))
		option_container.add_child(option)
	global_position.x-=size.x/2
	global_position.y-=size.y+30

func _on_option_pressed(index):
	print(index)
	emit_signal("option_selected", index)
	queue_free()


var index_mapping: Array = []

func set_index_mapping(mapping: Array):
	index_mapping = mapping

# 修改选项选择的信号发送
func _on_option_selected(local_index: int):
	# 使用映射将本地索引转换为原始索引
	var original_index = index_mapping[local_index]
	emit_signal("option_selected", original_index)
	queue_free()

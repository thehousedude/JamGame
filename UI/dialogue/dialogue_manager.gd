extends Node

var parser = ExpressionParser.new()
var evaluator = ExpressionEvaluator.new()


signal dialogue_started
signal dialogue_ended
signal player_interacted

@onready var dialogue_box_scene = preload("res://UI/dialogue/dialogbox.tscn")
var current_dialogue_box: Control = null

@onready var game_state = get_node("/root/GameState")

@onready var option_box_scene = preload("res://UI/dialogue/OptionBox.tscn")
var current_option_box: MarginContainer = null
var is_showing_options = false

var dialogue_data: Dictionary = {}
var current_language: String = "zh"  # 默认语言
var current_dialogue_index: int = 0
var current_dialogue_sequence: Array = []
var last_option_index:int=0
var advancable=false

func _ready():
	load_dialogue_data()

func load_dialogue_data():
	var file = FileAccess.open("res://UI/dialogue/dialogue_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			dialogue_data = json.get_data()
		file.close()
	else:
		print("Failed to load dialogue data")

func start_dialogue(dialogue_sequence: Array):
	if current_dialogue_box:
		end_dialogue()
	
	current_dialogue_sequence = dialogue_sequence
	current_dialogue_index = 0
	
	if not current_dialogue_sequence.is_empty():
		display_next_dialogue()
	else:
		print("No dialogue sequence provided")

func display_next_dialogue():
	while current_dialogue_index < current_dialogue_sequence.size():
		var dialogue_info = current_dialogue_sequence[current_dialogue_index]
		
		# 检查条件
		if not check_condition(dialogue_info):
			current_dialogue_index += 1
			continue  # 如果条件不满足，跳到下一个对话
		
		advancable = false
		
		if dialogue_info.has("option"):
			var position = dialogue_info.get("position", Vector2.ZERO)
			display_options(dialogue_info["option"],position)
			return
		else:
			var text = dialogue_info.get("text", "")
			var position = dialogue_info.get("position", Vector2.ZERO)
			
			if dialogue_info.has("id"):
				text = get_dialogue_text(dialogue_info["id"])
			
			if not current_dialogue_box:
				current_dialogue_box = dialogue_box_scene.instantiate()
				Gui.call_deferred("add_child", current_dialogue_box)
				current_dialogue_box.connect("finished_displaying", _on_dialogue_finished)
				emit_signal("dialogue_started")
			
			current_dialogue_box.global_position = position
			current_dialogue_box.call_deferred("_display_text", text)
			
			
			if dialogue_info.has("index"):
				# 处理标签
				pass
			if dialogue_info.has("jump"):
				# 处理跳转
				jump_to_index(dialogue_info["jump"])
			return  # 注意在成功显示对话后需要返回
		
	end_dialogue()
func display_options(options, position):
	var valid_options = []
	var index_mapping = []  # 存储有效选项与原始索引的映射
	
	# 遍历原始选项
	for i in range(options.size()):
		var option = options[i]
		var option_text = option[0]
		var jump_index = option[1]
		var option_conditions = {} if option.size() <= 2 else option[2]
		var is_valid_option = true
		
		if option_conditions.has("condition_method") or option_conditions.has("condition"):
			var temp_dialogue_info = option_conditions
			if not check_condition(temp_dialogue_info):
				is_valid_option = false
		
		if is_valid_option:
			valid_options.append([option_text, jump_index])
			index_mapping.append(i)  # 保存原始索引
	
	if valid_options.is_empty():
		# 如果没有有效选项，直接进入下一个对话
		advance_dialogue()
		return
	
	is_showing_options = true
	current_option_box = option_box_scene.instantiate()
	Gui.add_child(current_option_box)
	current_option_box.global_position = position
	current_option_box.setup_options(valid_options)
	
	# 将映射数组传递给选项框
	current_option_box.set_index_mapping(index_mapping)
	current_option_box.connect("option_selected", _on_option_selected)

func _on_option_selected(mapped_index: int):
	is_showing_options = false
	var selected_option = current_dialogue_sequence[current_dialogue_index]["option"][mapped_index]
	last_option_index=mapped_index
	jump_to_index(selected_option[1])


func jump_to_index(index):
	if index == "end":
		end_dialogue()
		return
		
	for i in range(current_dialogue_sequence.size()):
		if current_dialogue_sequence[i].has("index") and current_dialogue_sequence[i]["index"] == index:
			current_dialogue_index = i
			display_next_dialogue()
			return
	end_dialogue()

func advance_dialogue():
	if current_dialogue_box:
		current_dialogue_box.queue_free()
		await current_dialogue_box.tree_exited
	current_dialogue_index += 1
	call_deferred("display_next_dialogue")

func get_dialogue_text(dialogue_id: String) -> String:
	if dialogue_data.has(current_language) and dialogue_data[current_language].has(dialogue_id):
		return dialogue_data[current_language][dialogue_id]
	return "Dialogue not found"

func set_language(language: String):
	if dialogue_data.has(language):
		current_language = language
	else:
		print("Language not available")

func end_dialogue():
	if current_dialogue_box!=null:
		current_dialogue_box.queue_free()
	current_dialogue_box = null
	is_showing_options = false
	await get_tree().create_timer(.1).timeout
	emit_signal("dialogue_ended")

func _input(event):
	if is_showing_options:
		return  # 如果正在显示选项，则忽略所有输入
	
	if current_dialogue_box:
		if (event.is_action_pressed("ui_accept")) && advancable:
			emit_signal("player_interacted")
			advance_dialogue()
		elif event.is_action_pressed("ui_accept") && !advancable:
			skip_typing()


func skip_typing():
	if current_dialogue_box:
		current_dialogue_box._show_all_text()  # 显示所有字符

func _on_dialogue_finished():
	if current_dialogue_box:
		advancable=true


func check_condition(dialogue_info: Dictionary) -> bool:
	if dialogue_info.has("condition_method"):
		var method_info = dialogue_info["condition_method"]
		if method_info.size() == 0:
			return false
		var method_name = method_info[0]
		var args = method_info.slice(1)  # 获取方法的参数列表
		if game_state.has_method(method_name):
			var result = game_state.callv(method_name, args)
			return bool(result)  # 确保返回值是布尔值
		else:
			print("GameState does not have method:", method_name)
			return false
	elif dialogue_info.has("condition"):
		var condition = dialogue_info["condition"]
		if condition.ends_with("_flag"):
			# 检查标志
			var flag = condition.trim_suffix("_flag")
			return flag in game_state.flags
		else:
			# 评估数值条件
			print(condition)
			return evaluate_condition(condition)
	else:
		# 没有条件，默认返回真
		return true
		

func evaluate_condition(condition: String) -> bool:
	update_game_state()
	var ast = parser.parse(condition)
	return evaluator.evaluate(ast)

func update_game_state():
	evaluator.set_variable("coin", GameState.coin)

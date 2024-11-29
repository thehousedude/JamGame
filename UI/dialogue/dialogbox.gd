extends MarginContainer

@onready var text_label: Label = $MarginContainer/Label
@onready var timer: Timer = $Timer

const MAX_WIDTH = 1024


var text = ""
var letter_index = 0
var _stop_typing = false

@export var letter_time = 0.06
@export var space_time = 0.06
@export var punctuation_time = 0.2



signal finished_displaying()

func _display_text(text_to_display: String):
	# 重置状态
	visible=false
	text = text_to_display
	letter_index = 0
	_stop_typing = false
	
	# 设置初始文本以计算尺寸
	text_label.text = text_to_display
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# 等待一帧以确保尺寸计算完成
	await get_tree().process_frame
	
	# 调整容器大小
	var text_size = text_label.get_minimum_size()
	custom_minimum_size.x = min(text_size.x, MAX_WIDTH)
	
	# 如果超过最大宽度，重新计算高度
	if text_size.x > MAX_WIDTH:
		await get_tree().process_frame
		text_size = text_label.get_minimum_size()
		custom_minimum_size.y = text_size.y
	else:
		custom_minimum_size.y = text_size.y
	
	# 调整位置
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	
	# 清空文本开始打字效果
	text_label.text = ""
	visible=true
	_display_letter()

func _display_letter():
	if letter_index >= text.length():
		emit_signal("finished_displaying")
		return
		
	text_label.text += text[letter_index]
	
	if GlobalAudio:
		GlobalAudio.play_sound_effect(load("res://UI/dialogue/voice_blip.wav"))
	
	# 设置下一个字符的延迟时间
	var delay = letter_time
	if letter_index < text.length():
		match text[letter_index]:
			'，', '。', '！', '？', '!', ',', '.', '?':
				delay = punctuation_time
			' ':
				delay = space_time
	
	letter_index += 1
	timer.start(delay)

func _on_timer_timeout() -> void:
	if _stop_typing:
		return
	_display_letter()

func _show_all_text():
	_stop_typing = true
	text_label.text = text
	letter_index = text.length()
	emit_signal("finished_displaying")

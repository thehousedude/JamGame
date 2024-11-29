extends Node2D

@export var 插图列表: Array[Texture2D] = []
@export var 故事文本列表: Array[String] = []

@onready var 故事插图 = $"开场动画/Sprite2D"
@onready var 故事文本 = $"开场动画/Label"

var 是否开始游戏 = false
var 当前播放进度 = 0

func _ready() -> void:
	故事插图.texture = null
	故事文本.text = ""
	Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)
	$"提示文本".show()

func 开始游戏() -> void:
	get_tree().change_scene_to_file("res://Level/Rooms/test_room.tscn")

func _input(event):
	if event is InputEventKey and not 是否开始游戏:
		if event.pressed:
			$"提示文本".hide()
			播放下一张()
			是否开始游戏 = true

func 播放下一张() -> void:
	当前播放进度 += 1
	await Gui.fade(Color.BLACK, 0.5, Color(0, 0, 0, 0))
	Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)
	
	if 当前播放进度 <= 插图列表.size():
		故事插图.texture = 插图列表[当前播放进度 - 1]
		故事文本.text = 故事文本列表[当前播放进度 - 1]
		播放()
	elif 当前播放进度 == 插图列表.size() + 1:
		# 处理最后一段文本（没有配图的情况）
		故事插图.texture = null
		故事文本.position.y = 480
		故事文本.text = 故事文本列表[当前播放进度 - 1]
		播放()
	else:
		结束播放()

func 播放():
	故事文本.hide()
	await Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)
	故事文本.show()
	$"开场动画/AnimationPlayer".play("打字")

func 结束播放():
	当前播放进度 = 0
	$"开场动画".queue_free()
	开始游戏()

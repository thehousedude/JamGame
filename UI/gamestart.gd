extends Node2D

@export var 插图1:Texture2D
@export var 插图2:Texture2D
@export var 插图3:Texture2D
@export var 插图4:Texture2D
@export var 插图5:Texture2D
@export var 插图6:Texture2D

@export var 故事文本1:String
@export var 故事文本2:String
@export var 故事文本3:String
@export var 故事文本4:String
@export var 故事文本5:String
@export var 故事文本6:String
@export var 故事文本7:String

@onready var 故事插图 = $"开场动画/Sprite2D"
@onready var 故事文本 = $"开场动画/Label"

var 是否开始游戏 = false #仅用于判断按任意键能否开始游戏

func _ready() -> void:
	故事插图.texture = null
	故事文本.text = ""
	Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)
	$"提示文本".show()
	
func 开始游戏() -> void:
	GameManager.跳转场景("res://Level/Rooms/test_room.tscn") #跳转到起始场景
	
func _input(event): #按下任意按键开始游戏
	if event is InputEventKey and 是否开始游戏==false:
		if event.pressed:
			$"提示文本".hide()
			播放下一张()
			是否开始游戏 = true
	
var 当前播放进度=0
func 播放下一张() -> void: #根据播放进度按顺序播放开场动画
	当前播放进度+=1
	await Gui.fade(Color.BLACK, 0.5, Color(0, 0, 0, 0))
	Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK) #进行渐入和渐出
	if 当前播放进度==1:
		故事插图.texture = 插图1
		故事文本.text=故事文本1
		播放()
	if 当前播放进度==2:
		故事插图.texture = 插图2
		故事文本.text=故事文本2
		播放()
	if 当前播放进度==3:
		故事插图.texture = 插图3
		故事文本.text=故事文本3
		播放()
	if 当前播放进度==4:
		故事插图.texture = 插图4
		故事文本.text=故事文本4
		播放()
	if 当前播放进度==5:
		故事插图.texture = 插图5
		故事文本.text=故事文本5
		播放()
	if 当前播放进度==6:
		故事插图.texture = 插图6
		故事文本.text = 故事文本6
		播放()
	if 当前播放进度==7:
		故事插图.texture = null
		故事文本.position.y = 480
		故事文本.text = 故事文本7
		播放()
	if 当前播放进度==8:
		结束播放()
func 播放下一张2(): #交替播放模式 已废弃 可删除
	当前播放进度+=1
	if 当前播放进度==1:
		故事插图.texture = 插图1
		播放插图()
	if 当前播放进度==2:
		故事文本.text=故事文本1
		播放文本()
	if 当前播放进度==3:
		故事插图.texture = 插图2
		播放插图()
	if 当前播放进度==4:
		故事文本.text=故事文本2
		播放文本()
	if 当前播放进度==5:
		故事插图.texture = 插图3
		播放插图()
	if 当前播放进度==6:
		故事文本.text=故事文本3
		播放文本()
	if 当前播放进度==7:
		故事插图.texture = 插图4
		播放插图()
	if 当前播放进度==8:
		故事文本.text=故事文本4
		播放文本()
	if 当前播放进度==9:
		故事插图.texture = 插图5
		播放插图()
	if 当前播放进度==10:
		故事文本.text=故事文本5
		播放文本()
	if 当前播放进度==11:
		故事插图.texture = 插图6
		播放插图()
	if 当前播放进度 == 12:
		结束播放()	
func 播放文本(): #用于交替播放模式 已废弃 可删除
	await Gui.fade(Color.BLACK, 0.5, Color(0, 0, 0, 0))
	Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)	
	故事插图.hide()
	故事文本.show()
	$"开场动画/AnimationPlayer".play("打字")
func 播放插图(): #用于交替播放模式 已废弃 可删除
	Gui.fade(Color(0, 0, 0, 0), 1, Color.BLACK)	
	故事文本.hide()
	故事插图.show()
	
func 播放():
	故事文本.hide()
	await Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)
	故事文本.show()
	$"开场动画/AnimationPlayer".play("打字")

func 结束播放():
	当前播放进度=0
	$"开场动画".queue_free()
	开始游戏()
	
	

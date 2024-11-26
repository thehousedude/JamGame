extends Node2D

@onready var 提示 = $Label

func 开始游戏() -> void:
	GameManager.跳转场景("res://Level/Rooms/test_room.tscn") #跳转到起始场景
	提示.hide()
	
	

func _input(event): #按下任意按键开始游戏
	if event is InputEventKey:
		if event.pressed:
			开始游戏()

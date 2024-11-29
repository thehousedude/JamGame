@tool
extends MarginContainer


@export var 关卡等级=0
@export var 关卡路径:String
@export var 显示文字:String:
	set(value):
		显示文字=value
		$Button.text=value

@onready var button: Button = $Button

signal level_chosed(关卡路径)

func _ready() -> void:
	if GameState.通关关卡+1<关卡等级:
		button.disabled=true


func _on_button_pressed() -> void:
	emit_signal("level_chosed",关卡路径)

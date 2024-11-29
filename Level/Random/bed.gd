extends Area2D

@export var next_level_string:String


func _on_body_entered(body: Node2D) -> void:
	if body is Player and GameState.current_room_ins.get_teddy:
		body.start_interacting()
		if GameState.current_room_ins.关卡等级>GameState.通关关卡:
			GameState.通关关卡=GameState.current_room_ins.关卡等级
			GameState.SAVE_CONFIG()
		GameState.current_room_ins._change_room(next_level_string)

extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


signal teddy_got


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		teddy_got.emit()
		animation_player.play("got")
		await animation_player.animation_finished
		queue_free()

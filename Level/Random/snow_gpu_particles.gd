extends GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_filped=false

func _ready() -> void:
	GameState.new_player.connect(func():GameState.player.gravity_change.connect(gravity_changed))
	if GameState.player!=null:
		GameState.player.gravity_change.connect(gravity_changed)

func gravity_changed():
	is_filped=!is_filped
	if is_filped:
		animation_player.play("filp")
	else:
		animation_player.play_backwards("filp")

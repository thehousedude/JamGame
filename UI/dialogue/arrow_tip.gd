extends TextureRect

@export var amplitude: float = 1.0  # 浮动幅度
@export var frequency: float = 2.0   # 浮动频率

var time: float = 0.0
var initial_position: Vector2

func _ready():
	initial_position = position

func _physics_process(delta: float) -> void:
	time += delta
	var offset = sin(time * frequency) * amplitude
	position.y = initial_position.y + offset

extends Node2D
class_name Room
@onready var base_tile_map_layer: TileMapLayer = $BaseTileMapLayer
@onready var player: Player = $Player
@onready var player_game_camera: GameCamera = $GameCamera
@export var environment_music: AudioStream

@export var can_reset: bool = true 
var is_reseting=true


signal  readied

func _ready() -> void:
	player.start_interacting()
	
	GameState.current_room=name
	GameState.current_room_ins=self
	GameState.player=player
	var used = base_tile_map_layer.get_used_rect()
	var tile_size = base_tile_map_layer.tile_set.tile_size
	
	player_game_camera.limit_top = used.position.y * tile_size.y
	player_game_camera.limit_right = used.end.x * tile_size.x
	player_game_camera.limit_bottom = used.end.y * tile_size.y
	player_game_camera.limit_left = used.position.x * tile_size.x
	player_game_camera.reset_position()
	

	
	# 淡出效果
	await Gui.fade(Color(0, 0, 0, 0), 0.5, Color.BLACK)  # 淡出到透明


	# 播放环境音乐
	call_deferred("play_environment_music")

	player.end_interacting()
	is_reseting=false

func play_environment_music() -> void:
	if environment_music:
		# 检查当前播放的音乐是否与新的环境音乐相同
		if GlobalAudio.BGMplayer.stream != environment_music:
			GlobalAudio.play_music(environment_music)

func _change_room(room_string: String, room_connection: Resource) -> void:
	# 1. 淡入效果
	player.start_interacting()
	await Gui.fade(Color(0, 0, 0, 1), .5)  # 淡入到黑色


	# 2. 切换场景
	var new_scene_path = "res://Level/Rooms/" + room_string + ".tscn"
	var error = get_tree().change_scene_to_file(new_scene_path)
	if error != OK:
		push_error("Failed to change scene to " + new_scene_path)
		return


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_room") and can_reset and !is_reseting:  
		_reset_room()

func _reset_room() -> void:
	is_reseting=true
	# 1. 淡入效果
	player.start_interacting()
	await Gui.fade(Color(0, 0, 0, 1), .5)  # 淡入到黑色
	
	# 2. 重新加载当前场景
	var current_scene_path = scene_file_path
	var error = get_tree().change_scene_to_file(current_scene_path)
	if error != OK:
		push_error("Failed to reset room: " + current_scene_path)
	

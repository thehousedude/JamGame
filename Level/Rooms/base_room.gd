extends Node2D
class_name Room

@export var 关卡等级=0

@onready var base_tile_map_layer: TileMapLayer = $BaseTileMapLayer
@onready var player: Player = $Player
@onready var player_game_camera: GameCamera = $GameCamera
@onready var teddy: CharacterBody2D = $Teddy
@onready var center_marker: Marker2D = $CenterMarker
@onready var camera_move: Node2D = $CameraMove
@onready var white_line: TextureRect = $WhiteLine


@export var environment_music: AudioStream

@export var can_reset: bool = true 
var is_reseting=true

var get_teddy=false

signal  readied

func _ready() -> void:
	white_line.visible=false
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
	await _start_camera_show()
	player.end_interacting()
	is_reseting=false
	readied.emit()

func _start_camera_show():
	if camera_move.get_child_count()!=0:
		player_game_camera.set_follow_target(null)
		player_game_camera.move_to(player.global_position+Vector2(0,-20),1)
		for child in camera_move.get_children():
			player_game_camera.move_to(child.global_position,1)
			await get_tree().create_timer(1).timeout
		player_game_camera.move_to(player.global_position,1)
		await get_tree().create_timer(1.2).timeout
		player_game_camera.set_follow_target(player)


func play_environment_music() -> void:
	if environment_music:
		# 检查当前播放的音乐是否与新的环境音乐相同
		if GlobalAudio.BGMplayer.stream != environment_music:
			GlobalAudio.play_music(environment_music)

func _change_room(room_string: String) -> void:
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
	if event.is_action_pressed("shift"):
		white_line.visible=true
	if event.is_action_released("shift"):
		white_line.visible=false
		get_tree().change_scene_to_file("res://UI/Menus/choose_level_menu.tscn")

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
	



func _on_teddy_teddy_got() -> void:
	get_teddy=true

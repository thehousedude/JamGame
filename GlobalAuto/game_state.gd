#GameState
extends Node

const CONFIG_PATH:String="user://config.ini"
const SAVE_PATH = "user://save.json"

@export var flags=[]

func 拥有旗帜(旗帜名: String) -> bool:
	return flags.has(旗帜名)

# 添加一个新的旗帜，如果旗帜已存在则不重复添加
# 参数：
# - 旗帜名: 旗帜的名称
func 添加旗帜(旗帜名: String) -> void:
	if not 拥有旗帜(旗帜名):
		flags.append(旗帜名)

# 移除指定名称的旗帜，如果旗帜不存在则不执行任何操作
# 参数：
# - 旗帜名: 旗帜的名称
func 移除旗帜(旗帜名: String) -> void:
	if 拥有旗帜(旗帜名):
		flags.erase(旗帜名)

func save_game() -> void:
	var save_dict = {
		"flags": flags,
		"score":score
	}
	
	var json_string = JSON.stringify(save_dict)
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_line(json_string)

func has_save_file()->bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var save_dict = json.get_data()
		flags = save_dict["flags"]
		score=save_dict["score"]
		



signal new_player
signal new_room


@export var score=0
var player:Player
var current_room:String
var current_room_ins:Room:
	set(value):
		current_room_ins = value
		if current_room_ins != null:
			new_room.emit()

var game_camera:GameCamera


var last_room_connection:Resource=null

func _ready() -> void:
	call_deferred("LOAD_CONFIG")


func SAVE_CONFIG():
	var config=ConfigFile.new()
	
	config.set_value("audio","Master",GlobalAudio._get_volume(GlobalAudio.bus.Master))
	config.set_value("audio","BGM",GlobalAudio._get_volume(GlobalAudio.bus.BGM))
	config.set_value("audio","SFX",GlobalAudio._get_volume(GlobalAudio.bus.SFX))

	
	config.save(CONFIG_PATH)

func LOAD_CONFIG():
	var config=ConfigFile.new()
	var err=config.load(CONFIG_PATH)
	if err != OK:
		return
	
	GlobalAudio._set_volume(
		GlobalAudio.bus.Master,
		config.get_value("audio","Master")
	)
	GlobalAudio._set_volume(
		GlobalAudio.bus.BGM,
		config.get_value("audio","BGM")
	)
	GlobalAudio._set_volume(
		GlobalAudio.bus.SFX,
		config.get_value("audio","SFX")
	)

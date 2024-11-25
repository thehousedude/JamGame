extends Node

enum bus{Master,BGM,SFX}

func _get_volume(bus_index:int):
	var db=AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

func _set_volume(bus_index:int,v:float):
	var db=linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index,db)




@onready var BGMplayer: AudioStreamPlayer2D = $BGMplayer
@onready var SEplayers: Node = $SEplayers

var tween: Tween

func play_music(stream: AudioStream, volume: float = 0.0):
	if stream==null:
		stop_music()
		BGMplayer.stream = null
		return
	BGMplayer.stream = stream
	BGMplayer.volume_db = volume
	BGMplayer.play()

func stop_music():
	BGMplayer.stop()

func pause_music():
	BGMplayer.stream_paused = true

func resume_music():
	BGMplayer.stream_paused = false

func set_music_volume(volume: float):
	BGMplayer.volume_db = volume

func fade_music(from_volume: float, to_volume: float, duration: float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(BGMplayer, "volume_db", to_volume, duration).from(from_volume)

func play_sound_effect(stream: AudioStream, volume: float = 0.0):
	var available_player = find_available_se_player()
	if available_player:
		available_player.stream = stream
		available_player.volume_db = volume
		available_player.play()
	else:
		print("Warning: No available sound effect player!")

func find_available_se_player() -> AudioStreamPlayer2D:
	for player in SEplayers.get_children():
		if player is AudioStreamPlayer2D and not player.playing:
			return player
	return null

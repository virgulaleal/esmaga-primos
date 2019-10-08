extends Node

var last_typing_index: int
var channels: Dictionary

onready var json_parser = JsonParser

onready var sounds: Dictionary = json_parser.load_data("res://data/sounds.json")

func _ready() -> void:
	pass

func queue_add(channel: String, sound: Resource, volume: float, pitch: float, loop: = false):
	pass

func queue_start(channel: String):
	pass

func queue_play(channel: String):
	pass

func queue_skip(channel: String):
	pass

func queue_stop(channel: String):
	pass

func queue_pause(channel: String):
	pass

func speak(voice: String) -> void:
	var new_voice = Random.choose(sounds.voices[voice])
	var random_pitch = rand_range(0.8, 1.0)
	play_and_forget(new_voice, 0, random_pitch)

func play(channel: String, sound: String = "", volume: float = 0, pitch: float = 1, loop: = false):
	var player: AudioStreamPlayer
	if channel in channels.keys() and !loop:
		player = channels[channel].player
		player.stream = load(sound)
		player.play(channels[channel].playback_position)
		return
	else:
		player = AudioStreamPlayer.new()
	player = AudioStreamPlayer.new()
	player.set_name(channel)
	add_child(player)
	channels[channel] = {"player": player, "playback_position": 0.0}
	player.stream = load(sound)
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()
	yield(player, "finished")
	if loop:
		play(channel, sound, volume, pitch, true)
	if !loop:
		channels.erase(channel)
		player.queue_free()

func play_and_forget(sound: String = "", volume: float = 0, pitch: float = 1, loop: bool = false):
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(sound)
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play()
	yield(player, "finished")
	player.queue_free()
	

func stop(channel: String):
	pass

func resume(channel: String):
	var player: AudioStreamPlayer = channels[channel]["player"]
	player.play()

func pause(channel: String):
	var player: AudioStreamPlayer = channels[channel]["player"]
	channels[channel].playback_position = player.get_playback_position()
	player.stop()
	print("we pausing ", channel, ", it denotes player ", player)
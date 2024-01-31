extends Control

@export var bus_name: String
@export var bus_sfx_name: String

@export var settings: Control
@onready var play_sfx_button = $MarginContainer/GridContainer/SFXSetting/button_play
@onready var son_settings = $"../Musique"
@onready var sfx_settings = $sfx_settings
@onready var son_slider = $MarginContainer/GridContainer/MusicSetting/HSlider
@onready var sfx_slider = $MarginContainer/GridContainer/SFXSetting/HSlider

#var config_path = "user://usersave/config.cfg"
#@onready var config = ConfigFile.new()

func _ready():
	#var err = config.load(config_path)
	#var test_number = 0
	#while test_number < 5 and err != OK:
	#	err = config.load(config_path)
	#	test_number += 1
	#	
	#if err == OK:
	#	var bus_sfx = AudioServer.get_bus_index("SFX")
	#	var bus_music = AudioServer.get_bus_index("Music")
	#	Global.ping = config.get_value("PING","ping")
	#	var value_sfx = config.get_value("AUDIO","sfx")
	#	var value_music = config.get_value("AUDIO","music")
	#	
	#	if value_sfx > -24:
	#		AudioServer.set_bus_mute(bus_sfx, false)
	#		AudioServer.set_bus_volume_db(bus_sfx, value_sfx)
	#		sfx_slider.value = value_sfx
	#	else:
	#		AudioServer.set_bus_mute(bus_sfx, true)
	#		
	#	if value_music > -24:
	#		AudioServer.set_bus_mute(bus_music, false)
	#		AudioServer.set_bus_volume_db(bus_music, value_music)
	#		son_slider.value = value_music
	#	else:
	#		AudioServer.set_bus_mute(bus_music, true)
	pass

func _on_button_quit_pressed():
	#config.set_value("AUDIO", "music", son_slider.value)
	#config.set_value("AUDIO", "sfx", sfx_slider.value)
	#config.save(config_path)
	self.set_visible(false)
	settings.set_visible(true)

func _on_h_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if value > son_slider.min_value:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, value)
	else:
		AudioServer.set_bus_mute(bus_idx, true)

func _on_button_sfx_play_pressed():
	sfx_settings.play()

func _on_h_slider_sfx_value_changed(value):
	var bus_idx = AudioServer.get_bus_index(bus_sfx_name)
	if value > sfx_slider.min_value:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, value)
	else:
		AudioServer.set_bus_mute(bus_idx, true)

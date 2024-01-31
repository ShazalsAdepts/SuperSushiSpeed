extends Control

@export var bus_name: String
@export var bus_sfx_name: String

@export var settings: Control
@onready var play_sfx_button = $MarginContainer/GridContainer/SFXSetting/button_play
@onready var son_settings = $"../Musique"
@onready var sfx_settings = $sfx_settings
@onready var son_slider = $MarginContainer/GridContainer/MusicSetting/HSlider
@onready var sfx_slider = $MarginContainer/GridContainer/SFXSetting/HSlider


func _on_button_quit_pressed():
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

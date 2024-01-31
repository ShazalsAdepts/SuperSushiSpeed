extends Control

@export var settings: Control
@export var btn: OptionButton
var window_size = ["Widowed", "FullScreen", "Borderless"]
var index = 0
#var config_path = "user://usersave/config.cfg"
#@onready var config = ConfigFile.new()

func _ready():
	#var err = config.load(config_path)
	#var test_number = 0
	#
	#while test_number < 5 and err != OK:
	#	err = config.load(config_path)
	#	test_number += 1
	#
	#if err == OK:
	#	index = config.get_value("VIDEO","screen_id")
	#	if window_size[index] == "Widowed":
	#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#	elif window_size[index] == "FullScreen":
	#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	#	elif window_size[index] == "Borderless":
	#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#	
	#	btn.selected = index
	pass

func _on_button_quit_pressed():
	#config.set_value("VIDEO", "screen_id", index)
	#config.save(config_path)
	self.set_visible(false)
	settings.set_visible(true)

func _on_option_button_item_selected(index_tmp):
	index = index_tmp
	if window_size[index] == "Widowed":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif window_size[index] == "FullScreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif window_size[index] == "Borderless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

extends Control

@export var settings: Control
@export var btn: OptionButton
var window_size = ["Widowed", "FullScreen", "Borderless"]
var index = 0


func _on_button_quit_pressed():
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

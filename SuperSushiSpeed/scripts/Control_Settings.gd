extends Control

@export var menu: Control
@export var audio: Control

func _on_button_back_pressed():
	self.set_visible(false)
	menu.set_visible(true)


func _on_button_audio_pressed():
	self.set_visible(false)
	audio.set_visible(true)

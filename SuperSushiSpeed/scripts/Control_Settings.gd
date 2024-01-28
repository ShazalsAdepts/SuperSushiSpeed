extends Control

@export var menu: Control
@export var video: Control
@export var audio: Control
@export var controls: Control

func _on_button_audio_pressed():
	self.set_visible(false)
	audio.set_visible(true)

func _on_button_quit_pressed():
	self.set_visible(false)
	menu.set_visible(true)

func _on_button_video_pressed():
	self.set_visible(false)
	video.set_visible(true)


func _on_button_controls_pressed():
	self.set_visible(false)
	controls.set_visible(true)

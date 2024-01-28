extends Control

@export var menu: Control
@export var video: Control
@export var audio: Control
@export var controls: Control
@onready var input_button_scene = preload("res://default_bus_layout.tres")

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
	
func _on_button_calibration_pressed():
	get_tree().change_scene_to_file("res://scenes/calibration.tscn")

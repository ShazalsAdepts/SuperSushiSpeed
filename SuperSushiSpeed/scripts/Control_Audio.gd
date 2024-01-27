extends Control

@export var settings: Control


func _on_button_back_pressed():
	self.set_visible(false)
	settings.set_visible(true)


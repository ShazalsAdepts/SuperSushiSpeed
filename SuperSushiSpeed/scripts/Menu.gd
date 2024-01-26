extends Control


func _on_button_start_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_button_score_pressed():
	pass # Replace with function body.

func _on_button_settings_pressed():
	pass # Replace with function body.

func _on_button_quit_pressed():
	get_tree().quit()

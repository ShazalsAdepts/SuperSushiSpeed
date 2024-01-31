extends Control

@onready var fumee = $"../background/Terrain_1/RectangleStanding_4/GPUParticles3D"
@export var settings: Control


func _ready():
	fumee.emitting = false

func _on_button_start_pressed():
	SceneTransition.change_scene("scenes/count_down.tscn", 'dissolve')

func _on_button_settings_pressed():
	self.set_visible(false)
	settings.set_visible(true)

func _on_button_quit_pressed():
	get_tree().quit()

func _on_close_pressed():
	get_node("LeaderBoard").set_visible(false)

func _on_button_credits_pressed():
	get_node("HowToPlay").set_visible(true)
	get_node("LeaderBoard").set_visible(false)

func _on_close_htplay_pressed():
	get_node("HowToPlay").set_visible(false)

func _on_deco_pressed():
	Global.player_identifier = null
	get_node("deco").set_visible(false)
	get_node("Pseudo").set_visible(false)
	get_node("../Panel").set_visible(true)

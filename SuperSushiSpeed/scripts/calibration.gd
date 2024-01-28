extends Control

var temps_restant = 25
@export var son: AudioStreamPlayer
@export var label: Label
@export var label_ping: Label

var last_time = 26

var last_beat = 0.0

var time_tab = []

var started = false

func _ready():
	label.text = str(temps_restant)

func _physics_process(delta):
	if temps_restant > 0 and started:
		temps_restant -= delta  # Décrémenter le temps
		if last_time != int(temps_restant):
			last_beat = int(temps_restant)
			son.play()
			last_time = int(temps_restant)
			#$AnimationPlayer.play("GrowShrink")  # Remplacer par le chemin correct de votre AnimationPlayer

		label.text = str(int(temps_restant))
		
		if Input.is_action_just_pressed("ui_jump"):
			var time_pressed = temps_restant
			var difference_to_last_beat = abs(last_beat - time_pressed)
			var difference_to_next_beat = abs((last_beat + 1) - time_pressed) 

			var closest_difference = min(difference_to_last_beat, difference_to_next_beat)
			time_tab.append(closest_difference)
	elif started:
		label.text = ""
		label_ping.visible = true
		label_ping.text = str(sum(time_tab) / len(time_tab))
		started = false

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_start_pressed():
	started = true

func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result

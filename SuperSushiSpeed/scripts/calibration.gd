extends Control

@export var son: AudioStreamPlayer
@export var label: Label
@export var label_ping: Label
@export var label_ping_title: Label
@export var label_last_ping_title: Label

var temps_restant = 25
var last_time = 25
var last_beat = 0.0
var time_tab = []
var started = false
var ping = 0

var config_path = "res://usersave/config.cfg"
@onready var config = ConfigFile.new()

func _ready():
	var err = config.load(config_path)
	var test_number = 0
	while test_number < 5 and err != OK:
		err = config.load(config_path)
		test_number += 1
	
	if err == OK:
		Global.ping = config.get_value("PING","ping")
	label_last_ping_title.text = str(Global.ping)
	init()

func _physics_process(delta):
	if temps_restant > 0 and started:
		temps_restant -= delta  # Décrémenter le temps
		if last_time != int(temps_restant):
			last_beat = int(temps_restant)
			son.play()
			last_time = int(temps_restant)
			#$AnimationPlayer.play("GrowShrink")  # Remplacer par le chemin correct de votre AnimationPlayer

		label.text = str(int(temps_restant))
		
		if Input.is_action_just_pressed("ui_jump") and temps_restant < 20:
			var time_pressed = temps_restant
			var difference_to_last_beat = abs(last_beat - time_pressed)
			var difference_to_next_beat = abs((last_beat + 1) - time_pressed) 
			var closest_difference = min(difference_to_last_beat, difference_to_next_beat)
			time_tab.append(closest_difference)
			label_last_ping_title.text = str(closest_difference)
			
	elif started:
		label.text = ""
		label_ping.visible = true
		label_ping_title.visible = true
		if len(time_tab) != 0:
			ping = sum(time_tab) / len(time_tab)
			label_ping.text = str(ping)
			label_last_ping_title.text = str(ping)
		started = false

func _on_button_back_pressed():
	if ping != 0 and ping != 25:
		config.set_value("PING", "ping", ping)
		config.save(config_path)
		Global.ping = ping
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_start_pressed():
	init()
	started = true

func init():
	temps_restant = 25
	last_time = 25
	last_beat = 0.0
	time_tab = []
	started = false
	label_ping.visible = false
	label_ping_title.visible = false
	label.text = str(temps_restant)

func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result

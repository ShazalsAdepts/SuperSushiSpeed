extends Control  # Utilisez Node2D si vous êtes en 2D

var temps_restant = 4  # Durée du décompte en secondes
@export var son: AudioStreamPlayer
@export var label: Label

var last_time = 4

func _ready():
	label.text = str(temps_restant)  # Initialiser le texte du Label

func _physics_process(delta):
	if temps_restant > 0:
		temps_restant -= delta  # Décrémenter le temps
		if last_time != int(temps_restant):
			son.play()
			last_time = int(temps_restant)
		label.text = str(int(temps_restant))  # Mettre à jour le texte du Label
	else:
		get_tree().change_scene_to_file("res://scenes/world.tscn")  # Changer de scène

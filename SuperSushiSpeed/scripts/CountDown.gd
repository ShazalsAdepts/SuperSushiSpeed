extends Control  # Utilisez Node2D si vous êtes en 2D

var temps_restant = 4  # Durée du décompte en secondes
@export var son: AudioStreamPlayer
var last_time = 4
var labels : Array
func _ready():
	labels = [
		get_node("0"),
		get_node("1"),
		get_node("2"),
		get_node("3"),
		get_node("4")
	]

func _physics_process(delta):
	if temps_restant > 0:
		temps_restant -= delta  # Décrémenter le temps
		if last_time != int(temps_restant):
			son.play()
			last_time = int(temps_restant)
		update()
	else:
		get_tree().change_scene_to_file("res://scenes/world.tscn")  # Changer de scène

func update():
	for l in labels:
		l.set_visible(false)
	labels[last_time].set_visible(true)

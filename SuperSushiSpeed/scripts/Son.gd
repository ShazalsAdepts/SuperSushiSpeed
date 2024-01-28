extends AudioStreamPlayer

var next_beat_index = 0

var beats = []

@export var musique: AudioStreamPlayer
@export var player: CharacterBody3D

var last_click = 0.0

func _ready():
	load_beats("res://son/fuck_noel_beat_times.txt")

func load_beats(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			if line != "":
				beats.append(float(line))
		file.close()
	else:
		print("Failed to open file: ", path)

func _physics_process(delta):
	var current_position = musique.get_playback_position()
	
	if next_beat_index < beats.size() and current_position >= beats[next_beat_index]:
		self.play()  # Jouez le son "TAC"	
		next_beat_index += 1
	
	# Réinitialiser les beats lorsque la musique boucle
	if current_position < beats[next_beat_index - 1] and next_beat_index != 0:
		next_beat_index = 0
		player.restarted = true
	
	# Si vous voulez augmenter le pitch de la musique progressivement
	musique.pitch_scale += 0.003 * delta

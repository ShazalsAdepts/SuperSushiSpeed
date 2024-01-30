extends AudioStreamPlayer

var next_beat_index = 0

var beats = [
	0.08,
	0.10,
	0.65,
	1.10,
	1.55,
	1.85,
	2.45,
	3.05,
	3.35,
	3.50,
	3.95,
	4.25,
	4.85,
	5.45,
	5.85,
	6.35,
	6.60,
	7.21,
	7.80,
	8.15,
	8.25,
	8.75,
	9.05
]

@export var musique: AudioStreamPlayer
@export var player: CharacterBody3D

var last_click = 0.0

func _ready():
	pass
	#load_beats("res://son/fuck_noel_beat_times.txt")

func load_beats(path):
	var file = FileAccess.open(path, FileAccess.READ)
	print(file)
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
		if next_beat_index != 0:
			self.play()  # Jouez le son "TAC"	
		next_beat_index += 1
	
	# Réinitialiser les beats lorsque la musique boucle
	if current_position < beats[next_beat_index - 1] and next_beat_index != 0:
		next_beat_index = 0
		player.restarted = true
	
	# Si vous voulez augmenter le pitch de la musique progressivement
	musique.pitch_scale += 0.003 * delta

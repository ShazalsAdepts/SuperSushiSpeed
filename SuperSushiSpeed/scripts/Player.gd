extends CharacterBody3D

var MAX_SPEED = 95.0
var MIN_SPEED = 20.0
var SPEED = 50.0
const JUMP_VELOCITY = 9.0
var lerp_speed = 5.0

var last_foot_used = "none"
var consecutive_presses = 0

@export var terrain_controller: TerrainController
@export var player_camera: Camera3D
@export var musique: AudioStreamPlayer
@export var son: AudioStreamPlayer
@export var score_label: Label
@export var speed_label: Label
@export var rythme_label: Label

var rythme = ""

var score = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const X_LEFT = -2.0
const X_CENTER = 0.0
const X_RIGHT = 2.0
const step = 2.0

var current_lane = X_CENTER

var last_click = -1.0
var missed_beat_time = 0.2  # Le temps limite pour appuyer sur une touche pour trop tot / tard
var hors_rythme = 0.4 # Le temps limite pour appuyer sur une touche
var current_position = 0
var current_beat = 0.0
var current_beat_player = 0.0
var restarted = true
var can_miss = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * 3.0 * delta
	
	var foot_input = get_foot_input()
	if foot_input != "":
		handle_foot_movement(foot_input, delta)
	else:
		velocity.z = lerp(velocity.z, 0.0, delta * lerp_speed)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var target_x = current_lane
	var position = self.transform.origin
	position.x = lerp(position.x, target_x, delta * lerp_speed) # Mouv horizontal
	self.transform.origin = position
	
	if terrain_controller: # Le terrain déplace le joueur
		var terrain_velocity = terrain_controller.terrain_velocity
		translate(Vector3(0, 0, terrain_velocity/3 * delta))

	move_and_slide()
	handle_rythme()
	
	if player_camera and global_transform.origin.z > player_camera.global_transform.origin.z:
		die()
	
	score_label.text = str(score)
	speed_label.text = str(SPEED)
	rythme_label.text = str(rythme)

func get_foot_input():
	if Input.is_action_just_pressed("ui_left"):
		return "left"
	elif Input.is_action_just_pressed("ui_right"):
		return "right"
	return ""

func handle_rythme():
	current_position = musique.get_playback_position()

	if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")):
		var beat_time = son.beats[current_beat_player]
		var time_difference = current_position - beat_time
		
		if abs(time_difference) <= missed_beat_time:
			if SPEED < MAX_SPEED:
				SPEED += 10
			# Logique pour mouvement en rythme
			rythme = "ON TIME"
			update_next_beat_player_index(1)
		elif time_difference < -missed_beat_time and time_difference > -hors_rythme:
			if SPEED < MAX_SPEED:
				SPEED += 5
			# Logique pour trop tôt
			rythme = "TOO EARLY"
			update_next_beat_player_index(1)
		elif time_difference > missed_beat_time  and time_difference < hors_rythme:
			if SPEED < MAX_SPEED:
				SPEED += 5
			# Logique pour trop tard
			rythme = "TOO LATE"
			update_next_beat_player_index(1)
		else:
			# Hors rythme
			SPEED = MIN_SPEED
			rythme = "WUT ?!"

	elif (current_position > (son.beats[current_beat_player] + hors_rythme)) and restarted:
		# Beat manqué
		SPEED = MIN_SPEED
		rythme = "MISSED !"
		update_next_beat_player_index(0)

func update_next_beat_player_index(x):
	if (x == 0 and son.next_beat_index < son.beats.size()) or (x == 1 and son.next_beat_index + 1 < son.beats.size()):
		current_beat_player = son.next_beat_index + x
	elif current_beat_player != 0:
		current_beat_player = x
		restarted = false

func handle_foot_movement(foot, delta):
	if foot == last_foot_used:
		consecutive_presses += 1.0
		if consecutive_presses == 2.0:
			if foot == "left" and current_lane != X_LEFT:
				current_lane -= step
			elif foot == "right" and current_lane != X_RIGHT:
				current_lane += step
			consecutive_presses = 0.0
	else:
		consecutive_presses = 1.0
		velocity.z = lerp(velocity.z, -SPEED, delta * lerp_speed)
		
	last_foot_used = foot
	score += SPEED

func die():
	print(" ")
	print(" ")
	print("Le joueur est mort, SCORE : ", score)
	print(" ")
	print(" ")
	print(" FRED ")
	get_tree().quit()

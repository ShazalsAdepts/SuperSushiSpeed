extends CharacterBody3D

var MAX_SPEED = 95.0
var MIN_SPEED = 20.0
var SPEED = 50.0
const JUMP_VELOCITY = 8.0
var lerp_speed = 10.0

var last_foot_used = "none"
var consecutive_presses = 0

@export var terrain_controller: TerrainController
@export var player_camera: Camera3D
@export var musique: AudioStreamPlayer
@export var son: AudioStreamPlayer
@export var score_label: Label
@export var speed_label: Label
@export var rythme_label: Label
@export var game_over: Control
@export var speed_effect: ColorRect

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

var can_score = true

var target_fov = 75.0
var line_density = 0.00
var transition_speed = 0.9

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * 2 * delta
	
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
	handle_speed_effect(delta)
	
	if (player_camera and global_transform.origin.z > player_camera.global_transform.origin.z) or global_transform.origin.y < -1:
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
		if can_score :
			velocity.z = lerp(velocity.z, -SPEED, delta * lerp_speed)
		
	last_foot_used = foot
	update_score(SPEED)

func die():
	can_score = false
	game_over.set_score(score)
	await get_tree().create_timer(0.4).timeout
	game_over.visible = true
	gravity = 0

func update_score(x):
	if can_score == true:
		score += x

func handle_speed_effect(delta):
	if SPEED <= MIN_SPEED:
		line_density = 0.01
		target_fov = 70.0
	elif SPEED <= MIN_SPEED + 10:
		line_density = 0.03
		target_fov = 80.0
	elif SPEED <= MIN_SPEED + 30:
		line_density = 0.04
		target_fov = 90.0
	elif SPEED <= MIN_SPEED + 50:
		line_density = 0.05
		target_fov = 100.0
	else:
		line_density = 0.06
		target_fov = 110.0
	
	if !can_score:
		target_fov = 75.0
	
	var current_line_density = speed_effect.material.get_shader_parameter("line_density")
	speed_effect.material.set_shader_parameter("line_density", lerp(current_line_density, line_density, (transition_speed - 0.1) * delta))
	var current_fov = player_camera.fov
	player_camera.fov = lerp(current_fov, target_fov, transition_speed * delta)

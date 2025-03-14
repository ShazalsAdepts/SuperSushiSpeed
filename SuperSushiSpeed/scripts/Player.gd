extends CharacterBody3D

var MAX_SPEED = 95.0
var MIN_SPEED = 0.00
var SPEED = 20.0
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

@onready var sprite = $Sushi
@onready var hitbox = $PlayerHitbox

var rythme = ""
var last_rythme = ""
var score = 0


var combo = 0
var last_combo = 0
var best_combo = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const X_LEFT = -2.0
const X_CENTER = 0.0
const X_RIGHT = 2.0
const step = 2.0

var current_lane = X_CENTER

var x_start = 100
var x_end = 1074

var last_click = -1.0
var missed_beat_time = 0.2  # Le temps limite pour appuyer sur une touche pour trop tot / tard
var hors_rythme = 0.4 # Le temps limite pour appuyer sur une touche
var current_position = 0
var current_beat = 0.0
var current_beat_player = 0.0
var restarted = true
var can_miss = true

var on_time = 0
var late = 0
var not_late = 0
var mist = 0


var can_score = true

var target_fov = 75.0
var line_density = 0.00
var transition_speed = 0.9

var SLIDE_SPEED = 50.0
const SLIDE_TIME = 0.5
const SLIDE_ROTATION_START = 4.8  # Début de rotation pour le slide
const SLIDE_ROTATION_END = 0.0      # Fin de rotation après le slide
const ROTATION_INTERP_SPEED = 8  # Vitesse d'interpolation de la rotation

var sliding = false
var slide_timer = SLIDE_TIME
var can_slide = true

var can_double_jump = true
var jump_counter = 0

var unlock_double_jump = true
var unlock_slide = true

var is_mutated = false
var multiply = 1

@onready var slide_cooldown_timer = $slide_cooldown_timer
@onready var mutation_cooldown_timer = $mutation_cooldown_timer
@onready var sushi_muscle = load("assets/sushi/sushiV2MOOSCLES.obj")
@onready var sushi_muscle_slide = load("assets/sushi/sushiV2Flex1.obj")
@onready var sushi_normal = load("assets/sushi/sushiV2.obj")
@onready var sushi_normal_right = load("assets/sushi/sushiV2Right.obj")
@onready var sushi_normal_left = load("assets/sushi/sushiV2Left.obj")
@onready var sushi_muscle_right = load("assets/sushi/sushiV2MOOSCLESRight.obj")
@onready var sushi_muscle_left = load("assets/sushi/sushiV2MOOSCLESLeft.obj")

func _on_ready():
	pass
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * 2 * delta
	else:
		jump_counter = 0
	
	var foot_input = get_foot_input()
	if foot_input != "":
		handle_foot_movement(foot_input, delta)
	else:
		velocity.z = lerp(velocity.z, 0.0, delta * lerp_speed)
	
	handle_slide(delta)
	handle_jump()
	handle_lane_position(delta)
	
	if terrain_controller: # Le terrain déplace le joueur
		var terrain_velocity = terrain_controller.terrain_velocity
		translate(Vector3(0, 0, terrain_velocity/3 * delta))
	
	if is_mutated:
		MAX_SPEED = 145.0
		unlock_double_jump = true
		multiply = 2
	else:
		MAX_SPEED = 95.0
		if SPEED > 100.0 :
			SPEED = 100.0
		unlock_double_jump = false
		multiply = 1
		
	handle_trail()
	check_lane(delta)
	move_and_slide()
	handle_rythme()
	handle_speed_effect(delta)
	
	"""
	var balls = [
		get_node("ball"),
		get_node("ball1"),
		get_node("ball2"),
		get_node("ball3"),
		get_node("ball4"),
		get_node("ball5"),
		get_node("ball6")
	]
	var i = 0
	for ball in balls:
		ball.set_visible(false)
	"""
	
	for ballss in son.beats:
		var inco = ballss- musique.get_playback_position()
		if inco < 0.1 && inco > 0:
				get_node("Panel3/AnimationPlayer").play("beats_up")
	
	"""
	var dif = 0
	for income in range(2):
		for rly_income in range(1, 23):
			var beats_time = son.beats[rly_income]
			var incoming_in = beats_time - (dif -  musique.get_playback_position())
			if incoming_in < 2 && incoming_in > 0:
				balls[i].set_visible(true)
				var x = ((incoming_in)*974)/2+100
				balls[i].position.x = x
				balls[i].position.y = 576
				i = i +1
		dif = musique.stream.get_length() #* 1 / musique.pitch_scale
	"""
	
	if (player_camera and global_transform.origin.z > player_camera.global_transform.origin.z + 0.3) or global_transform.origin.y < -1:
		die()
	
	handle_ui()

func handle_ui():
	score_label.text = str(score)
	rythme_label.text = str(rythme)
	
	if rythme != last_rythme:
		last_rythme = rythme
		if rythme == "NANI ?!" || rythme == "ON TIME":
			get_node("title_rythme/AnimationPlayer").play("add_")
		else:
			get_node("title_rythme/AnimationPlayer").play("add")
		
	if combo != last_combo:
		last_combo = combo
		get_node("combo/AnimationPlayer").play("add")
		if combo > best_combo:
			best_combo = combo
	get_node("combo").text = str(combo)
	var speed_bar = get_node("SPEED")
	speed_bar.size.x = 52 + (SPEED * 148)/100
	speed_bar["theme_override_styles/panel"].region_rect = Rect2(0,0,83.72 +(SPEED * 238.78)/100,219)
	
	var dash = get_node("DASH")
	var timer = get_node("slide_cooldown_timer")
	if timer.is_stopped():
		dash.size.x = 52 + (100 * 148)/100
		dash["theme_override_styles/panel"].region_rect = Rect2(0,0,83.72 +(100 * 238.78)/100,219)
	else:
		dash.size.x = 52 + ((5-timer.get_time_left()) * 148)/5
		dash["theme_override_styles/panel"].region_rect = Rect2(0,0,83.72 +((5 -timer.get_time_left()) * 238.78)/5,219)
	
	var mutation = get_node("mutation_cooldown_timer")
	var wasabi = get_node("wasabi")
	if mutation.is_stopped():
		wasabi.size.x = 515
		wasabi["theme_override_styles/panel"].region_rect = Rect2(0,0,926,259)
	else:
		wasabi.size.x = (mutation.get_time_left() *515)/5
		wasabi["theme_override_styles/panel"].region_rect = Rect2(0,0,(mutation.get_time_left()*929)/5,259)

func handle_lane_position(delta):
	var target_x = float(int(current_lane))
	var position_player = self.transform.origin
	position_player.x = lerp(position_player.x, target_x, delta * lerp_speed) # Mouv horizontal
	self.transform.origin = position_player

func handle_slide(delta):
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			end_slide()
		else:
			velocity.z = lerp(velocity.z, -SLIDE_SPEED, delta * lerp_speed)
			SLIDE_SPEED -= 1
	elif unlock_slide and can_slide and Input.is_action_just_pressed("ui_shift"):
		start_slide()

func handle_jump():
	if Input.is_action_just_pressed("ui_jump") and (is_on_floor() or can_double_jump):
		if jump_counter == 0:
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
			jump_counter += 1
		elif unlock_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false

func handle_trail():
	if SPEED >= 100 and is_mutated:
		find_child("TrailsSPEED").emitting = true
		find_child("Trails").emitting = false
	elif SPEED >= 100 and not is_mutated:
		find_child("TrailsSPEED").emitting = false
		find_child("Trails").emitting = true
	else:
		find_child("TrailsSPEED").emitting = false
		find_child("Trails").emitting = false

func check_lane(delta):
	var position_player = self.transform.origin
	var target_x = float(current_lane)

	if position_player.x == target_x:
		return
	
	var lerp_factor = delta * 0.1 
	var tmp = lerp(position_player.x, target_x, lerp_factor)
	self.transform.origin.x = tmp

	if abs(self.transform.origin.x - target_x) < 0.1:
		self.transform.origin.x = target_x
	elif position_player.x < target_x:
		self.transform.origin.x += 0.05
	elif position_player.x > target_x:
		self.transform.origin.x -= 0.05

func get_foot_input(): 
	if Input.is_action_just_pressed("ui_left"):
		return "left"
	elif Input.is_action_just_pressed("ui_right"):
		return "right"
	return ""

func _on_AnimationPlayer_animation_finished(anim_name):
	get_node("Panel3/AnimationPlayer").pause("beats_up")

func handle_rythme():
	current_position = musique.get_playback_position()

	if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")):
		var beat_time = son.beats[current_beat_player]
		var time_difference = current_position - Global.ping - beat_time
		
		if abs(time_difference) <= missed_beat_time:
			if SPEED < MAX_SPEED:
				SPEED += 10 * multiply
			elif SPEED == 95:
				SPEED = 100.0
			# Logique pour mouvement en rythme
			rythme = "ON TIME"
			on_time += 1
			combo+=2
			update_next_beat_player_index(1)
		elif time_difference < -missed_beat_time and time_difference > -hors_rythme:
			if SPEED < MAX_SPEED:
				SPEED += 5 * multiply
			# Logique pour trop tôt
			rythme = "TOO EARLY"
			not_late += 1
			combo += 1
			update_next_beat_player_index(1)
		elif time_difference > missed_beat_time  and time_difference < hors_rythme:
			if SPEED < MAX_SPEED:
				SPEED += 5 * multiply
			# Logique pour trop tard
			rythme = "TOO LATE"
			late += 1
			combo += 1
			update_next_beat_player_index(1)
		else:
			# Hors rythme
			if current_beat_player != 0 and current_beat_player != 1:
				SPEED = MIN_SPEED
				rythme = "NANI ?!"
				mist += 1
				combo = 0

	elif (current_position > (son.beats[current_beat_player] + hors_rythme)) and restarted:
		# Beat manqué
		if current_beat_player != 0 and current_beat_player != 1:
			SPEED = MIN_SPEED
			rythme = "MISSED !"
			combo = 0
		update_next_beat_player_index(0)

func update_next_beat_player_index(x):
	if son.next_beat_index + x < son.beats.size():
		current_beat_player = son.next_beat_index + x
	elif current_beat_player != 0:
		current_beat_player = x
		restarted = false

func handle_foot_movement(foot, delta):
	if foot == last_foot_used:
		consecutive_presses += 1.0
		if consecutive_presses == 2.0:
			if !is_mutated:
				find_child("Sushi").mesh = sushi_normal
			else:
				find_child("Sushi").mesh = sushi_muscle
			if foot == "left" and current_lane != X_LEFT:
				current_lane -= step
				current_lane = float(int(current_lane))
			elif foot == "right" and current_lane != X_RIGHT:
				current_lane += step
				current_lane = float(int(current_lane))
			consecutive_presses = 0.0
	else:
		if foot == "left":
			if !is_mutated:
				find_child("Sushi").mesh = sushi_normal_left
			else:
				find_child("Sushi").mesh = sushi_muscle_left
		else: 
			if !is_mutated:
				find_child("Sushi").mesh = sushi_normal_right
			else:
				find_child("Sushi").mesh = sushi_muscle_right
		consecutive_presses = 1.0
		if can_score :
			velocity.z = lerp(velocity.z, -SPEED, delta * lerp_speed)
		
	last_foot_used = foot
	update_score(SPEED)

func die():
	can_score = false
	game_over.set_score(score, best_combo,on_time,late,not_late,mist)
	await get_tree().create_timer(0.1).timeout
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

func start_slide():
	SLIDE_SPEED = 30.0
	sliding = true
	can_slide = false
	slide_timer = SLIDE_TIME
	slide_cooldown_timer.start()
	self.rotation.x = SLIDE_ROTATION_START
	self.position.y -= 0.3

func end_slide():
	if is_mutated:
		find_child("Sushi").mesh = sushi_muscle
	sliding = false
	self.rotation.x = SLIDE_ROTATION_END
	self.position.y += 1.3

func _on_slide_cooldown_timer_timeout():
	can_slide = true
	get_node("slide_cooldown_timer").stop()

func mutate(x):
	update_score(x)
	if !is_mutated:
		get_node('greenwasabu/AnimationPlayer').play("comming")
	is_mutated = true
	mutation_cooldown_timer.start()
	find_child("Sushi").mesh = sushi_muscle

func _on_mutation_cooldown_timer_timeout():
	get_node("mutation_cooldown_timer").stop()
	find_child("Sushi").mesh = sushi_normal
	get_node('greenwasabu/AnimationPlayer').play("leave")
	is_mutated = false

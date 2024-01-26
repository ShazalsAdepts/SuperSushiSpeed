extends Camera3D

@export var player: CharacterBody3D
var initial_pos = Vector3()
var follow_distance = -4.0
var smooth_speed = 5.0 
var follow_distance_y = -2.0

func _ready():
	initial_pos = global_transform.origin

func _physics_process(delta):
	if player != null:
		var player_pos = player.global_transform.origin
		var camera_pos = global_transform.origin

		if player_pos.z - camera_pos.z < follow_distance:
			var target_z = player_pos.z - follow_distance
			camera_pos.z = lerp(camera_pos.z, target_z, delta * smooth_speed)
			
		if player_pos.y - camera_pos.y > follow_distance_y:
			var target_y = player_pos.y - follow_distance_y
			camera_pos.y = lerp(camera_pos.y, target_y, delta * smooth_speed)
		
		if player_pos.y - camera_pos.y < follow_distance_y:
			var target_y = player_pos.y - follow_distance_y
			camera_pos.y = lerp(camera_pos.y, target_y, delta * smooth_speed)
		
		global_transform.origin = camera_pos
	else:
		print("Player node not found")

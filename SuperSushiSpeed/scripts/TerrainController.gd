extends Node3D

class_name TerrainController

var TerrainBlocks: Array = []
var terrain_belt: Array[MeshInstance3D] = []

@export var player: CharacterBody3D

var acceleration: float = 0.02
var max_speed: float = 20.0
var terrain_velocity: float = 0.8
var num_terrain_blocks = 15
var terrian_blocks_path = "modules"
var some_threshold = 60.0

var spawn_height = -10.0
var rise_speed = 5.0

func _ready() -> void:
	_load_terrain_scenes(terrian_blocks_path)
	_init_blocks(num_terrain_blocks)

func _physics_process(delta: float) -> void:
	_progress_terrain(delta)
	_increase_speed(delta)
	
	if _needs_new_block():
		_add_new_block()

func _needs_new_block() -> bool:
	return player.global_transform.origin.z - terrain_belt[-1].global_transform.origin.z < some_threshold

func _add_new_block() -> void:
	var block = TerrainBlocks.pick_random().instantiate()
	_append_to_far_edge(terrain_belt[-1], block)
	add_child(block)
	terrain_belt.append(block)

	if terrain_belt.size() > num_terrain_blocks:
		var first_terrain = terrain_belt.pop_front()
		first_terrain.queue_free()

func _increase_speed(delta: float) -> void:
	if terrain_velocity < max_speed:
		terrain_velocity += acceleration * delta

func _init_blocks(number_of_blocks: int) -> void:
	if TerrainBlocks[0] == null:
		_load_terrain_scenes(terrian_blocks_path)
	for block_index in number_of_blocks:
		var block
		if block_index == 0:
			block = TerrainBlocks[0].instantiate()
			block.position.z = -block.mesh.size.y/3
		else:
			block = TerrainBlocks.pick_random().instantiate()
			_append_to_far_edge(terrain_belt[block_index-1], block)
		add_child(block)
		terrain_belt.append(block)

func _progress_terrain(delta: float) -> void:
	
	for block in terrain_belt:
		block.position.z += terrain_velocity * delta

	if terrain_belt[0].position.z >= terrain_belt[0].mesh.size.y:
		var last_terrain = terrain_belt[-1]
		var first_terrain = terrain_belt.pop_front()

		var block = TerrainBlocks.pick_random().instantiate()
		_append_to_far_edge(last_terrain, block)
		add_child(block)
		terrain_belt.append(block)
		first_terrain.queue_free()

func _append_to_far_edge(target_block: MeshInstance3D, appending_block: MeshInstance3D) -> void:
	appending_block.position.z = target_block.position.z - target_block.mesh.size.y/2 - appending_block.mesh.size.y/2

func _load_terrain_scenes(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for i in range(20):
		var r = ResourceLoader.load("res://modules/terrain_"+str(i)+".tscn")
		TerrainBlocks.append(r)

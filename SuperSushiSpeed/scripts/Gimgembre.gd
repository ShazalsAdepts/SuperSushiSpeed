extends Area3D

@onready var player = $"../../../Player"

func _on_body_entered(body):
	if player :
		player.mutate(500)
		queue_free()

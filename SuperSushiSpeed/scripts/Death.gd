extends Control
var score : int
var combo : int

var score_set: bool = false
var play_anim = true # changé pour tester si ca enlève le virus mdr

func _process(delta):
	if play_anim == true:
		get_node("best/AnimationPlayer").play("wow")

func _on_restart_pressed():
	get_tree().change_scene_to_file("scenes/count_down.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("scenes/menu.tscn")

func set_score(x,y,on_time,late,not_late,mist):
	if score_set == false:
		score = x
		combo = y
		get_node("combo").text = str(y)
		get_node("label_score").text = str(x)
		get_node("beatsmiss").text = str(mist+late+not_late)
		get_node("perfect").text = str(on_time)
		score_set = true

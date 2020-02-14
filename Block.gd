extends Node

const dropblock = preload("res://Block.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()
	pass
	

func spawn():
	while (true):
		randomize()
		var block = dropblock.instance()
		var randomx = Vector2(rand_range(1,1000),14)
		block.set_position(randomx)
		add_child(block)
		yield(get_tree().create_timer(rand_range(0.25,1.25)), "timeout")
	pass

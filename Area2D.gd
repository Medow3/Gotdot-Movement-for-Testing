extends Area2D

var motion = Vector2()
var fallfactor = 200		# change for block gravity factor

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func _physics_process(delta):
	motion.y = fallfactor*delta
	translate(motion)


# removes from scene when leaves screen view
func _on_VisibilityEnabler2D_screen_exited():
	queue_free()


func TimerTimeout():
	pass # Replace with function body.

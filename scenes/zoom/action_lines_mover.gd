extends Sprite2D

const DISTANCE_TO_MOVE = 960

var direction: int = LEFT
enum { LEFT = -1, RIGHT = 1 }

func _ready():
	ScriptManager.register_handler("action_lines.set_direction", _handle_action_lines_set_direction)

func _handle_action_lines_set_direction(args: Dictionary):
	match args.get("dir", "left"):
		"left":
			direction = LEFT
		"right":
			direction = RIGHT
		var dir:
			Utils.print_error("Direction \"%s\" not valid for actionlines command (must be \"left\" or \"right\")" % dir)

func _set_direction(new_direction: int):
	direction = new_direction

func _process(delta):
	position.x += DISTANCE_TO_MOVE * delta * direction

	if direction == LEFT:
		while position.x < -256:
			position.x += 256
	elif direction == RIGHT:
		while position.x > 256:
			position.x -= 256

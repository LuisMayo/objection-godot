extends Node2D

@export var confetti_scene: PackedScene

var _flakes: Array[ConfettiFlake] = []

func _ready():
    ScriptManager.register_handler("confetti.start", _handle_confetti_start)
    ScriptManager.register_handler("confetti.stop", _handle_confetti_stop)

func _handle_confetti_start(args: Dictionary):
    var num_flakes: int = int(args.get("count", "31"))
    spawn_confetti(num_flakes)

func _handle_confetti_stop(_args: Dictionary):
    delete_confetti()

func delete_confetti():
    for f in _flakes:
        f.queue_free()
    _flakes.clear()

func spawn_confetti(num_flakes: int = 31):
    delete_confetti()
    for i in num_flakes:
        var flake: ConfettiFlake = confetti_scene.instantiate() as ConfettiFlake
        _flakes.append(flake)

        # Adapted from a decompilation of Ace Attorney GBA
        # https://github.com/atasro2/pwaa1/blob/795f03f2c5337d01ea6ce87f6a81b53a0de2a466/src/court.c#L704
        flake.position.x = fmod(randi_range(0, 31) + (i * 32), 256)
        flake.position.y = fmod(randi() + (i * 32), 127)

        add_child(flake)

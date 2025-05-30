extends Control

const MARKERS = ["happy", "sad", "angry", "surprised"]

@onready var _happy_marker: MoodMatrixMarker = %Happy
@onready var _sad_marker: MoodMatrixMarker = %Sad
@onready var _angry_marker: MoodMatrixMarker = %Angry
@onready var _surprised_marker: MoodMatrixMarker = %Surprised

@export_group("Noise Textures")
@export var large_noise_texture: Texture2D
@export var small_noise_texture: Texture2D

var _shake_frame: bool = false

func _ready():
	ScriptManager.register_handler("mood_matrix.bootup.animate_in", _handle_mood_matrix_bootup_animate_in)
	ScriptManager.register_handler("mood_matrix.ui.animate_in", _handle_mood_matrix_ui_animate_in)
	ScriptManager.register_handler("mood_matrix.ui.animate_in_overload", _handle_mood_matrix_ui_animate_in_overload)
	ScriptManager.register_handler("mood_matrix.ui.set_overload_tints", _handle_mood_matrix_ui_set_overload_tints)

	ScriptManager.register_handler("mood_matrix.ui.set_visible", _handle_mood_matrix_ui_set_visible)

	ScriptManager.register_handler("mood_matrix.ui.set_emotion_level", _handle_mood_matrix_ui_set_emotion_level)
	ScriptManager.register_handler("mood_matrix.ui.reset_marker_positions", _handle_mood_matrix_ui_reset_marker_positions)

	%Bootup.sound_should_be_played.connect(%BootupSound.play)
	%Bootup.white_flash.connect(func():
		var a = create_tween()
		%WhiteFlash.visible = true
		%WhiteFlash.color.a = 0.0
		a.tween_property(%WhiteFlash, "color:a", 1.0, 0.09)
	)

	%OverloadWarning.self_modulate.a = 0.0
	%OverloadWarningExclamationMark.visible = false
	%BehindMarkersWhiteFlash.visible = false

func _process(delta):
	if _shake_frame:
		%Frame.position = lerp(%Frame.position, Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0)), delta * 10.0)
	else:
		%Frame.position = lerp(%Frame.position, Vector2.ZERO, delta * 10.0)

func set_markers_thinking():
	_happy_marker.set_thinking()
	_sad_marker.set_thinking()
	_angry_marker.set_thinking()
	_surprised_marker.set_thinking()

func set_markers_inactive():
	_happy_marker.set_inactive()
	_sad_marker.set_inactive()
	_angry_marker.set_inactive()
	_surprised_marker.set_inactive()

func set_markers_active():
	_happy_marker.set_active()
	_sad_marker.set_active()
	_angry_marker.set_active()
	_surprised_marker.set_active()

func do_intro_pulse():
	_happy_marker.do_intro_pulse_anim()
	_sad_marker.do_intro_pulse_anim()
	_angry_marker.do_intro_pulse_anim()
	_surprised_marker.do_intro_pulse_anim()

func animate_markers_in(play_sound: bool = true):
	if play_sound:
		%RestartSound.play()
	%WhiteFlash.visible = false
	%WhiteFlash.color.a = 0.0
	$AnimationPlayer.play("markers_in")
	await $AnimationPlayer.animation_finished

func animate_bootup():
	var bootup_anim: AnimationPlayer = %Bootup.get_node("AnimationPlayer")
	bootup_anim.play("intro")
	await bootup_anim.animation_finished
	bootup_anim.play("RESET")

func _handle_mood_matrix_bootup_animate_in(_args: Dictionary):
	await animate_bootup()

func _handle_mood_matrix_ui_animate_in(args: Dictionary):
	var play_sound: bool = args.get("play_sound", "true") == "true"
	await animate_markers_in(play_sound)

func _handle_mood_matrix_ui_set_visible(args: Dictionary):
	var value: bool = args.get("value", "true") == "true"
	if value:
		$AnimationPlayer.assigned_animation = "markers_in"
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length, true, true)
	else:
		$AnimationPlayer.play("RESET")

func _handle_mood_matrix_ui_set_emotion_level(args: Dictionary):
	# <mood_matrix.emotion type="happy" intensity="3" />
	var markers = {
		"happy": _happy_marker,
		"sad": _sad_marker,
		"angry": _angry_marker,
		"surprised": _surprised_marker
	}
	
	var emotion_str = args.get("type", "")
	if emotion_str not in markers:
		Utils.print_error("Emotion \"%s\" doesn't exist in Mood Matrix" % emotion_str)
		return
	
	var do_overload = args.get("overload", "false") == "true"

	var marker = markers[emotion_str]
	var intensity = float(args.get("intensity", "1"))

	marker.set_pulse(intensity, do_overload)

func _handle_mood_matrix_ui_animate_in_overload(args: Dictionary):
	var emotions_to_keep = args.get("emotions", "").split(",")
	var markers = {
		"happy": _happy_marker,
		"sad": _sad_marker,
		"angry": _angry_marker,
		"surprised": _surprised_marker
	}

	var overload_tw := create_tween()
	overload_tw.tween_callback(%OverloadSound.play)
	overload_tw.tween_callback(_animate_bg_noise_spike)
	overload_tw.tween_callback(_animate_overload_symbol)
	overload_tw.tween_callback(_animate_big_shake)
	overload_tw.tween_callback(func():
		_happy_marker.set_thinking()
		_sad_marker.set_thinking()
		_angry_marker.set_thinking()
		_surprised_marker.set_thinking()
	)

	for e in emotions_to_keep:
		if e not in markers:
			Utils.print_error("Emotion \"%s\" doesn't exist" % [e])
			continue
		overload_tw.tween_callback(markers[e].animate_overload)

	overload_tw.tween_interval(1.0)
	overload_tw.tween_callback(func(): _shake_frame = true)
	overload_tw.tween_callback(%BigRing.start_ring_noise)
	overload_tw.tween_interval(2.66)

	# White flash, other emotions move out
	overload_tw.tween_callback(func(): %BehindMarkersWhiteFlash.visible = true)

	const OFFSET_MAGNITUDE = 80
	const OFFSET_DURATION = 0.2

	# This is a bit scrunkly but I'm tired and wanna get this done. Maybe another
	# day I'll refactor it to be more streamlined.
	if "happy" not in emotions_to_keep:
		overload_tw.parallel().tween_property(%HappyOffset, "position", Vector2.from_angle(7 * PI / 4) * OFFSET_MAGNITUDE, OFFSET_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if "angry" not in emotions_to_keep:
		overload_tw.parallel().tween_property(%AngryOffset, "position", Vector2.from_angle(5 * PI / 4) * OFFSET_MAGNITUDE, OFFSET_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if "surprised" not in emotions_to_keep:
		overload_tw.parallel().tween_property(%SurprisedOffset, "position", Vector2.from_angle(3 * PI / 4) * OFFSET_MAGNITUDE, OFFSET_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if "sad" not in emotions_to_keep:
		overload_tw.parallel().tween_property(%SadOffset, "position", Vector2.from_angle(1 * PI / 4) * OFFSET_MAGNITUDE, OFFSET_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	overload_tw.tween_callback(func(): %BehindMarkersWhiteFlash.visible = false).set_delay(0.03)

	overload_tw.tween_interval(5.0 - 2.66 - 0.2 - OFFSET_DURATION - 1.0)
	overload_tw.tween_callback(func(): _shake_frame = false)
	
	await overload_tw.finished

func _animate_bg_noise_spike():
	var move_tween := create_tween()

	%BGNoiseSpike.position.x = 0.0
	move_tween.tween_property(%BGNoiseSpike, "position:x", -10.0, 0.2)

	var scale_tween := create_tween()
	%BGNoiseSpike.scale.y = 0.0
	scale_tween.tween_property(%BGNoiseSpike, "scale:y", 4.0, 0.06)
	scale_tween.tween_property(%BGNoiseSpike, "scale:y", 0.0, 0.16)

	var change_sprites_tween := create_tween()
	for i in %BGNoiseSpike.get_children():
		if i is not TextureRect:
			continue
		i.texture = large_noise_texture

	change_sprites_tween.tween_callback(func():
		for i in %BGNoiseSpike.get_children():
			if i is not TextureRect:
				continue
			i.texture = small_noise_texture
	).set_delay(0.1)

func _animate_overload_symbol():
	var tw := create_tween()
	tw.tween_callback(func(): %OverloadWarning.self_modulate.a = 1.0)
	tw.tween_interval(1.2)
	tw.tween_property(%OverloadWarning, "self_modulate:a", 0.0, 0.1)

	var excl_tw := create_tween()
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = true)
	excl_tw.tween_interval(0.3)
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = false)
	excl_tw.tween_interval(0.3)
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = true)
	excl_tw.tween_interval(0.3)
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = false)
	excl_tw.tween_interval(0.3)
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = true)
	excl_tw.tween_interval(0.3)
	excl_tw.tween_callback(func(): %OverloadWarningExclamationMark.visible = false)

func _animate_big_shake():
	var tw := create_tween()
	const BIG_SHAKE_MAGNITUDE = 3.0
	const BIG_SHAKE_DURATION = 0.06
	tw.tween_property(%Frame, "position:x", BIG_SHAKE_MAGNITUDE, BIG_SHAKE_DURATION / 2.0)
	for i in 3:
		tw.tween_property(%Frame, "position:x", -BIG_SHAKE_MAGNITUDE, BIG_SHAKE_DURATION)
		tw.tween_property(%Frame, "position:x", BIG_SHAKE_MAGNITUDE, BIG_SHAKE_DURATION)
	tw.tween_property(%Frame, "position:x", 0.0, BIG_SHAKE_DURATION / 2.0)

func _handle_mood_matrix_ui_reset_marker_positions(_args: Dictionary):
	%HappyOffset.position = Vector2.ZERO
	%AngryOffset.position = Vector2.ZERO
	%SurprisedOffset.position = Vector2.ZERO
	%SadOffset.position = Vector2.ZERO

func _handle_mood_matrix_ui_set_overload_tints(args: Dictionary):
	var emotions = args.get("emotions", "").split(",")
	var tints: Array[Color] = []
	if "happy" in emotions:
		tints.append(_happy_marker.marker_type.background_color_active)
	if "angry" in emotions:
		tints.append(_angry_marker.marker_type.background_color_active)
	if "surprised" in emotions:
		tints.append(_surprised_marker.marker_type.background_color_active)
	if "sad" in emotions:
		tints.append(_sad_marker.marker_type.background_color_active)
	%OverloadTint.set_tints(tints)
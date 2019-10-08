extends NinePatchRect

# lê-se em média 15.46 letras por segundo
# 0.064 * numero de letras

export(bool) var speech = false
export(float) var frequency = 0.05
export(bool) var permanent = false

var message_stack: Array = []

var state = states.idle
enum states {
	idle,
	processing
}

onready var tween: Tween = $Tween
onready var timer: Timer = $Timer

func _ready():
	pass

func output(message: String, set_permanent: bool = false) -> void:
	message_stack.append(message)
	permanent = set_permanent
	if state == states.idle:
		process_stack()

func process_stack() -> void: if message_stack.size() > 0:
	var current_message = message_stack[0]
	state = states.processing
	message_stack.pop_front()
	if speech:
		visible = true
	$Label.percent_visible = 0
	$Label.text = current_message
	tween.interpolate_property(
		$Label,
		"percent_visible",
		0,
		1,
		current_message.length() * frequency,
		Tween.EASE_IN,
		Tween.EASE_IN_OUT,
		0
	)
	tween.start()
	timer.start(0.2)

func _on_Timer_timeout() -> void:
	if $Label.visible_characters > 0:
		var random_pitch = rand_range(1, 0.96)
		var random_vox = "res://assets/sound/vox-bla/bla-0" + String(Random.roll("1d3")) + ".ogg"
		SoundManager.play("voice", random_vox, -10, random_pitch)
		# print("waiting on a sound manager, pitch: ", random_pitch)
	else:
		print("done")
		timer.stop()

func _on_Tween_tween_all_completed() -> void:
	if speech and !permanent:
		yield(get_tree().create_timer($Label.text.length() * 0.064), "timeout")
		visible = false
	state = states.idle
	process_stack()
	

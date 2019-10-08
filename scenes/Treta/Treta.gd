extends Control

const letter_duration = 0.055

var player: Dictionary = {
	id = "erro",
	nome = "erro",
	universo = "erro",
	ai = "erro",
	max_hp = 45,
	hp = 45,
	max_ki = 20,
	ki = 20
}
var opponent: Dictionary = {
	id = "erro",
	nome = "erro",
	universo = "erro",
	ai = "erro",
	max_hp = 45,
	hp = 45,
	max_ki = 20,
	ki = 20
}

var state = states.idle
enum states {
	idle,
	player_acting,
	opponent_acting,
	game_over
}

onready var bonecos = JsonParser.load_data("res://data/bonecos.json")

onready var nodes: Dictionary = {
	op_boneco = $Oponente/Boneco,
	player_boneco = $Player/Boneco,
	player_hpbar = $PlayerStats/PlayerHP,
	player_kibar = $PlayerStats/PlayerKi,
	op_hpbar = $OpStats/OpHP,
	op_speech = $OpSpeechPanel,
	player_speech = $PlayerSpeechPanel,
	action_panel = $ActionPanel
}

func _ready() -> void:
	initialize(bonecos["rival-amigavel"], bonecos["placeholder"])
	update_ui()
	nodes.op_speech.output("Eu só quero conversar!")
	nodes.action_panel.output("rival amigável veio encher o saco!")

func _process(delta: float) -> void:
	if state == states.idle:
		$ActionPanel/AgredirBtn.disabled = false
		$ActionPanel/GritarBtn.disabled = false
		$ActionPanel/RegenerarBtn.disabled = false
	elif state != states.game_over:
		$ActionPanel/AgredirBtn.disabled = true
		$ActionPanel/GritarBtn.disabled = true
		$ActionPanel/RegenerarBtn.disabled = true

# INITS

func initialize(opponent_data: Dictionary, avatar_data: Dictionary):
	initialize_player(avatar_data)
	initialize_opponent(opponent_data)

func initialize_player(avatar_data: Dictionary):
	player = avatar_data
	nodes.player_boneco.initialize(avatar_data, "avatares")

func initialize_opponent(opponent_data: Dictionary):
	opponent = opponent_data
	nodes.op_boneco.initialize(opponent_data)

# INPUT
func player_input(input: String) -> void: if state == states.idle: match input:
	"attack":
		state = states.player_acting
		yield(move("attack", player, opponent), "completed")
		state = states.opponent_acting
		yield(opponent_turn(), "completed")
		if state != states.game_over:
			state = states.idle
	"heal":
		state = states.player_acting
		yield(move("heal", player, player), "completed")
		state = states.opponent_acting
		yield(opponent_turn(), "completed")
		if state != states.game_over:
			state = states.idle
	"restore":
		state = states.player_acting
		yield(move("restore", player, player), "completed")
		state = states.opponent_acting
		yield(opponent_turn(), "completed")
		if state != states.game_over:
			state = states.idle
	_:
		print("invalid input: ", input)

# MOVES
func move(move_id: String, source: Dictionary, target: Dictionary) -> void:
	var amount: int
	var formatting: Array
	var new_string: String
	var string_duration: float
	match move_id:
		"attack":
			amount = Random.roll("1d8") + 1
			formatting = [source.nome, target.nome, amount]
			new_string = "{0} agride {1}, causando {2} danos!"
			damage(target, amount)
			SoundManager.play_and_forget("res://assets/sound/porrada.ogg", rand_range(0.8, 1.2))
			nodes.op_boneco.animate("impact")
			nodes.op_boneco.emote("raiva")
			yield(get_tree().create_timer(0.5), "timeout")
		"heal":
			var cost = Random.roll("1d4") - 1
			amount = Random.choose([8, 9, 10, 14], [2, 2, 1, 1])
			spend_ki(source, cost)
			heal(target, amount)
			if source == target:
				formatting = [source.nome, amount]
				new_string = "{0} cura {1} danos!"
			else:
				formatting = [source.nome, amount, target.nome]
				new_string = "{0} cura {1} danos de {2}!"
		"restore":
			amount = Random.choose([5, 6, 7, 8], [2, 2, 1, 1])
			restore_ki(target, amount)
			if source == target:
				formatting = [source.nome, amount]
				new_string = "{0} recupera {1} pontos de ki!"
			else:
				formatting = [source.nome, amount, target.nome]
				new_string = "{0} concede {1} pontos de ki para {2}!"
		"steal_ki":
			amount = Random.roll("1d4")
			formatting = [source.nome, amount, target.nome]
			new_string = "{0} reapropria {1} pontos do ki de {2}!"
			spend_ki(target, amount)
			restore_ki(source, amount)
		"arcade_heal":
			var cost = 4
			amount = 4
			formatting = [source.nome, amount]
			new_string = "{0} regenera {1} danos!"
			spend_ki(source, cost)
			heal(target, amount)
		"arcade_attack":
			amount = Random.roll("1d6") + 1
			formatting = [source.nome, target.nome, amount]
			new_string = "{0} reage contra {1}, causando {2} danos!"
			damage(target, amount)
			SoundManager.play_and_forget("res://assets/sound/porrada.ogg", rand_range(0.8, 1.2))
			nodes.player_boneco.animate("impact")
			nodes.player_boneco.emote("raiva")
		_:
			print("movimento ilegal: ", move_id)
	update_ui()
	new_string = new_string.format(formatting)
	nodes.action_panel.output(new_string)
	string_duration = new_string.length() * letter_duration
	yield(get_tree().create_timer(string_duration), "timeout")
	yield(get_tree().create_timer(0.5), "timeout")
	

# AI
func opponent_turn():
	match opponent.ai:
		"arcade":
			if Random.prob(99) and opponent.hp > 0:
				var random_lines: Array = [
					"eu não vim brigar.",
					"você não sabe o que está fazendo.",
					"eu não sou seu verdadeiro inimigo.",
					"bora tomar umas depois disso?",
					"esta não é a sua verdadeira força.",
					"ei, que brincadeira é essa?",
					"em que situação fomos nos meter?",
					"escandaloso.",
					"devo me manter neutro.",
					"não. não aqui."
				]
				nodes.op_speech.output(Random.choose(random_lines))
			if opponent.ki <= 0 or opponent.hp <= 0:
				nodes.op_boneco.emote("raiva", -1)
				nodes.op_speech.output("chega, eu me rendo!")
			elif opponent.ki <= 5 and Random.prob(70):
				yield(move("steal_ki", opponent, player), "completed")
			elif opponent.hp <= 10 and opponent.ki > 4:
				yield(move("arcade_heal", opponent, opponent), "completed")
			else:
				yield(move("arcade_attack", opponent, player), "completed")
	if player.ki <= 0:
		damage(player, 14)
		SoundManager.play_and_forget("res://assets/sound/porrada.ogg", rand_range(0.8, 1.2))
		nodes.player_boneco.animate("impact")
		nodes.player_speech.output("argh! estou sem ki!")
	update_ui()
	if player.hp <= 0:
		state = states.game_over
		nodes.op_speech.output("não é nada pessoal!")
		nodes.action_panel.output("você perdeu!")
	yield(get_tree().create_timer(0.005), "timeout")
	

# STATS
func damage(target: Dictionary, amount: int) -> void:
	target.hp = max(0, target.hp - amount)

func heal(target: Dictionary, amount: int) -> void:
	target.hp = min(target.max_hp, target.hp + amount)

func spend_ki(target: Dictionary, amount: int) -> void:
	target.ki = max(0, target.ki - amount)

func restore_ki(target: Dictionary, amount: int) -> void:
	target.ki = min(target.max_ki, target.ki + amount)

# UI
func update_ui():
	nodes.player_hpbar.update_value(player.hp, player.max_hp)
	nodes.player_kibar.update_value(player.ki, player.max_ki)
	nodes.op_hpbar.update_value(opponent.hp, opponent.max_hp)
	#update_opponent_stats()
	#update_player_stats()

func update_player_stats():
	var player_hp: String = String(player.hp)
	var player_ki: String = String(player.ki)

# SIGNALING
func _on_AgredirBtn_pressed() -> void:
	player_input("attack")

func _on_GritarBtn_pressed() -> void:
	player_input("restore")

func _on_RegenerarBtn_pressed() -> void:
	player_input("heal")

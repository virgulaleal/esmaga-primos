extends Sprite
class_name Boneco

export(String) var id = "rival_amigavel"

var emotion_state = "normal"
var sprites: Dictionary = {
	normal = "res://assets/art/oponentes/erro/erro-normal.png",
	raiva = "res://assets/art/oponentes/erro/erro-raiva.png",
	triste = "res://assets/art/oponentes/erro/erro-triste.png",
	contente = "res://assets/art/oponentes/erro/erro-contente.png"
}

# temp, please make use of a boneco manager
onready var bonecos = JsonParser.load_data("res://data/bonecos.json")

func _ready():
	initialize(bonecos["rival-amigavel"])

func initialize(boneco: Dictionary, tipo = "oponentes") -> void:
	var boneco_dir = "res://assets/art/" + tipo + "/" + boneco.id + "/"
	var boneco_alias = boneco_dir + boneco.id + "-"
	self.id = boneco.id
	self.sprites = {
		normal = boneco_alias + "normal.png",
		raiva = boneco_alias + "raiva.png",
		triste = boneco_alias + "triste.png",
		contente = boneco_alias + "contente.png"
	}
	self.emotion_state = "normal"
	self.texture = load(self.sprites.normal)

func animate(animation_id: String, loop: bool = false) -> void:
	$AnimationPlayer.play(animation_id)
	if loop:
		pass

func emote(emotion_id: String, duration: float = 0.35):
	var current_emotion = self.emotion_state
	self.emotion_state = emotion_id
	self.texture = load(self.sprites[emotion_id])
	if duration > 0:
		yield(get_tree().create_timer(duration), "timeout")
		self.emotion_state = current_emotion
		self.texture = load(self.sprites[current_emotion])
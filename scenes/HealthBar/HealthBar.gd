extends TextureProgress

export(bool) var number_visible = true

func _ready() -> void:
	initialize()

func _process(delta: float) -> void:
	$Label.text = String(value)

func initialize() -> void:
	$Label.visible = number_visible
	$Label.text = String(value)

func update_value(new_value, new_maximum) -> void:
	var tween = $Tween
	self.max_value = new_maximum
	tween.interpolate_property(
		self,
		"value",
		self.value,
		new_value,
		0.5,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT,
		0
	)
	tween.start()
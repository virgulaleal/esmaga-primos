extends Node

func _ready():
	randomize()

func choose(kwargs: Array, weights: Array = []):
	if weights.size() >= 0 and weights.size() == kwargs.size():
		var weighted_kwargs: Array = []
		for index in kwargs.size():
			for weight in weights[index]:
				weighted_kwargs.append(kwargs[index])
		return weighted_kwargs[randi() % weighted_kwargs.size()]
	else:
		return kwargs[randi() % kwargs.size()]

func weight_choose(kwargs: Array):
	pass

func roll(dice_notation: String) -> int:
	var split: Array = dice_notation.split("d", false, 2)
	var amount: int = int(split[0])
	var faces: int = int(split[1])
	var result: int = 0
	for roll_index in amount:
		var roll_result = randi() % faces + 1
		result += roll_result
	return result

func prob(probability: float) -> bool:
	var result: float  = rand_range(0, 100)
	return result <= probability
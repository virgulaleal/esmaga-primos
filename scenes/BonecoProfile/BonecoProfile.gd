extends Control

func _ready():
	$SpeechPanelRigth.output("escandaloso.", true)


func _on_CreditsLabel_meta_clicked(meta) -> void:
	OS.shell_open("https://twitter.com/virgulaleal")

extends Node


# Atributos export
export(String, FILE, "*.tscn") var escena_siguiente
export(String, FILE, "*.tscn") var nivel_inicial


func _on_ButtonContinuar_pressed() -> void:
	
	MusicaJuego.play_boton()
	get_tree().change_scene(escena_siguiente)


func _on_ButtonEmpezarJuego_pressed() -> void:
	
	MusicaJuego.play_boton()
	get_tree().change_scene(nivel_inicial)

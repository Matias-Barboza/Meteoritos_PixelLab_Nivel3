extends Node


# Atributos export
export(String, FILE, "*.tscn") var nivel_inicial


# Metodos
func _ready() -> void:
	
	#OS.set_window_fullscreen(true)
	MusicaJuego.play_musica(MusicaJuego.get_lista_musicas().menu_principal)


func _on_ButtonJugar_pressed() -> void:
	
	MusicaJuego.play_boton()
	get_tree().change_scene(nivel_inicial)


func _on_ButtonSalir_pressed() -> void:
	
	get_tree().quit()

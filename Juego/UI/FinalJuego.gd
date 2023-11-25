extends Node


func _ready() -> void:
	
	MusicaJuego.play_musica(MusicaJuego.get_lista_musicas().menu_principal)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ButtonSalir_pressed() -> void:
	
	get_tree().quit()

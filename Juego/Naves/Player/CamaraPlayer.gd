class_name CameraPlayer
extends CamaraJuego


#Atributos export
export var variacion_zoom : float = 0.1
export var zoom_minimo : float = 0.8
export var zoom_maximo : float = 1.5


# Metodos
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("zoom_in"):
		controlar_zoom(-variacion_zoom)
	elif event.is_action_pressed("zoom_out"):
		controlar_zoom(variacion_zoom)


func controlar_zoom(mod_zoom) -> void:
	
	zoom.x = clamp(zoom.x + mod_zoom, zoom_minimo, zoom_maximo)
	zoom.y = clamp(zoom.y + mod_zoom, zoom_minimo, zoom_maximo)
	zoom_suavizado(zoom.x, zoom.y, 0.15)

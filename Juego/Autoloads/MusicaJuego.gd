extends Node


# Atributos export
export var tiempo_transicion : float = 4.0
export(float, -50.0, -20.0, 5.0) var volumen_apagado = -40.0


# Atributos
var volumen_original_musica_off : float = 0.0


# Atributos onready
onready var musica_nivel : AudioStreamPlayer = $MusicaNivel
onready var musica_combate : AudioStreamPlayer = $MusicaCombate
onready var tween_musica_on : Tween = $TweenMusicaOn
onready var tween_musica_off : Tween = $TweenMusicaOff
onready var lista_musicas : Dictionary = {
	"menu_principal" : $MusicaMenuPrincipal
} setget ,get_lista_musicas


# Metodos
func set_streams(stream_musica : AudioStream, stream_combate : AudioStream) -> void:
	
	musica_nivel.stream = stream_musica
	musica_combate.stream = stream_combate


func play_musica_nivel() -> void:
	
	stop_todo()
	musica_nivel.play()


func stop_todo() -> void:
	
	for nodo in get_children():
		if nodo is AudioStreamPlayer:
			nodo.stop()


func play_musica(musica : AudioStreamPlayer) -> void:
	
	stop_todo()
	musica.play()


func play_boton() -> void:
	
	$BotonMenu.play()


func transicion_musicas() -> void:
	
	if musica_nivel.playing:
		fade_in(musica_combate)
		fade_out(musica_nivel)
	else:
		fade_in(musica_nivel)
		fade_out(musica_combate)


func fade_in(musica_fade_in : AudioStreamPlayer) -> void:
	
	var volumen_original = musica_fade_in.volume_db
	musica_fade_in.volume_db = volumen_apagado
	musica_fade_in.play()
	tween_musica_on.interpolate_property(
		musica_fade_in,
		"volume_db",
		volumen_apagado,
		volumen_original,
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	tween_musica_on.start()


func fade_out(musica_fade_out : AudioStreamPlayer) -> void:
	
	volumen_original_musica_off = musica_fade_out.volume_db
	tween_musica_off.interpolate_property(
		musica_fade_out,
		"volume_db",
		musica_fade_out.volume_db,
		volumen_apagado,
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	tween_musica_off.start()


func _on_TweenMusicaOff_tween_completed(object : Object, _key : NodePath) -> void:
	
	object.stop()
	object.volume_db = volumen_original_musica_off


func get_lista_musicas() -> Dictionary:
	
	return lista_musicas

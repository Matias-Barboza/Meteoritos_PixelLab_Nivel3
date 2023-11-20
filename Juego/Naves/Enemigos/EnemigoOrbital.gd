class_name EnemigoOrbital
extends EnemigoBase


# Atributos export
export var rango_max_ataque : float = 1400.0
export var velocidad : float = 400.0


var base_duenia : Node2D = null
var ruta : Path2D
var ruta_a_seguir : PathFollow2D


onready var detector_obstaculo : RayCast2D = $DetectorObstaculo


func _ready() -> void:
	
	Eventos.connect("base_destruida", self, "_on_base_destruida")
	canion.set_esta_disparando(true)


func _process(delta: float) -> void:
	
	ruta_a_seguir.offset += velocidad * delta
	position = ruta_a_seguir.global_position


func crear(posicion : Vector2, duenia : Node2D, ruta_duenia : Path2D) -> void:
	
	global_position = posicion
	base_duenia = duenia
	ruta = ruta_duenia
	ruta_a_seguir = PathFollow2D.new()
	ruta.add_child(ruta_a_seguir)


func rotar_hacia_player() -> void:
	
	.rotar_hacia_player()
	if dir_player.length() > rango_max_ataque or detector_obstaculo.is_colliding():
		canion.set_esta_disparando(false)
	else:
		canion.set_esta_disparando(true)


func _on_base_destruida(base : Node2D, _posiciones : Array) -> void:
	
	if base == base_duenia:
		destruir()


func _on_Animation_player_animation_finished(anim_name : String) -> void:
	
	._on_AnimationPlayer_animation_finished(anim_name)

class_name Escudo
extends Area2D


# Atributos export
export var energia : float = 8.0
export var radio_desgaste : float = -1.6


# Atributos
var esta_activado : bool = false setget ,get_esta_activado
var energia_original : float


# Atributos onready
onready var colisionador : CollisionShape2D = $CollisionShape2D
onready var animaciones : AnimationPlayer = $AnimationPlayer


# Metodos
func _ready() -> void:
	
	energia_original = energia
	
	set_process(false)
	controlar_colisionador(true)


func _process(delta: float) -> void:
	
	controlar_energia(radio_desgaste * delta)


func controlar_energia(consumo : float) -> void:
	
	energia += consumo
	
	if energia > energia_original:
		energia = energia_original
	elif energia < 0.0:
		Eventos.emit_signal("ocultar_energia_escudo")
		desactivar()
		return
	
	Eventos.emit_signal("cambio_energia_escudo", energia_original, energia)


func activar() -> void:
	
	if energia < 0.0:
		return
	
	esta_activado = true
	controlar_colisionador(false)
	set_process(true)
	animaciones.play("activando")


func desactivar() -> void:
	
	set_process(false)
	esta_activado = false
	controlar_colisionador(true)
	animaciones.play_backwards("activando")


func controlar_colisionador(esta_desactivado : bool) -> void:
	
	colisionador.set_deferred("disabled", esta_desactivado)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if anim_name == "activando" and esta_activado:
		animaciones.play("activado")


func get_esta_activado() -> bool:
	
	return esta_activado


func _on_Escudo_body_entered(body: Node) -> void:
	
	body.queue_free()

class_name Canion
extends Node2D

#Atributos export
export var proyectil : PackedScene = null
export var cadencia_disparo : float = 0.4
export var velocidad_proyectil : int = 1500
export var danio_proyectil : int = 1

#Atributos onready
onready var timer_enfriamiento : Timer = $TimerEnfriamiento
onready var sfx_disparo : AudioStreamPlayer2D = $SFXDisparo
onready var esta_enfriado : bool = true
onready var esta_disparando : bool = false setget set_esta_disparando

var puntos_disparo : Array = []
var puede_disparar : bool = false setget set_puede_disparar

func _ready() -> void:
	almacenar_puntos_disparo()
	timer_enfriamiento.wait_time = cadencia_disparo


func _process(_delta: float) -> void:
	if esta_disparando and esta_enfriado and puede_disparar:
		disparar()


func almacenar_puntos_disparo() -> void:
	for nodo in get_children():
		if nodo is Position2D:
			puntos_disparo.append(nodo)


func disparar() -> void:
	
	esta_enfriado = false
	sfx_disparo.play()
	timer_enfriamiento.start()
	
	for punto_disparo in puntos_disparo:
		var new_proyectil : Proyectil = proyectil.instance()
		new_proyectil.crear(
			punto_disparo.global_position,
			get_owner().rotation,
			velocidad_proyectil,
			danio_proyectil
		)
		Eventos.emit_signal("disparo", new_proyectil)


func set_esta_disparando(disparando : bool) -> void:
	esta_disparando = disparando


func set_puede_disparar(estado_disparar : bool) -> void:
	puede_disparar = estado_disparar


func _on_TimerEnfriamiento_timeout() -> void:
	esta_enfriado = true

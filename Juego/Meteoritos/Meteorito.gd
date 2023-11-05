class_name Meteorito
extends RigidBody2D


#Atributos export
export var vel_lineal_base : Vector2 = Vector2(300.0, 300.0)
export var vel_angular_base : float = 3.0
export var hitpoints_base : float = 10.0


#Atributos
var hitpoints : float
var esta_en_sector : bool = true setget set_esta_en_sector
var posicion_original_spawn : Vector2 = Vector2.ZERO
var velocidad_original_spawn : Vector2 = Vector2.ZERO
var esta_destruido : bool = false


onready var animaciones : AnimationPlayer = $AnimationPlayer
onready var sfx_impacto : AudioStreamPlayer2D = $SFXImpacto


#Metodos
func _ready() -> void:
	
	angular_velocity = vel_angular_base


func crear(pos : Vector2, dir : Vector2, tamanio : float):
	
	position = pos
	posicion_original_spawn = position
	#Calcular Masa, tamaño de sprite y de Colisionador
	mass *= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	#Radio = diametro / 2
	var radio : int = int ($Sprite.texture.get_size().x / 2.3 * tamanio)
	var forma_colision : CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	#Calcular velocidades
	linear_velocity = (vel_lineal_base * dir / tamanio) * aleatorizar_velocidad()
	angular_velocity = (vel_angular_base / tamanio) * aleatorizar_velocidad()
	velocidad_original_spawn = linear_velocity
	#Calcular hitpoints
	hitpoints = hitpoints_base * tamanio


func destruir():
	
	$CollisionShape2D.set_deferred("disabled", true)
	Eventos.emit_signal("destruccion_meteorito", global_position)
	queue_free()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	
	if esta_en_sector:
		return
	
	var mi_transform := state.get_transform()
	mi_transform.origin = posicion_original_spawn
	linear_velocity = velocidad_original_spawn
	state.set_transform(mi_transform)
	esta_en_sector = true


func recibir_danio(danio : float) -> void:
	
	hitpoints -= danio
	
	if hitpoints < 0.0 and not esta_destruido:
		esta_destruido = false
		destruir()
	
	sfx_impacto.play()
	animaciones.play("impacto")


func aleatorizar_velocidad() -> float:
	
	randomize()
	return rand_range(1.1, 1.4)


func set_esta_en_sector(valor : bool) -> void:
	
	esta_en_sector = valor

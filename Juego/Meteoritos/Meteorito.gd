class_name Meteorito
extends RigidBody2D


#Atributos export
export var vel_lineal_base : Vector2 = Vector2(300.0, 300.0)
export var vel_angular_base : float = 3.0
export var hitpoints_base : float = 10.0


#Atributos
var hitpoints : float


onready var animaciones : AnimationPlayer = $AnimationPlayer
onready var sfx_impacto : AudioStreamPlayer2D = $SFXImpacto


#Metodos
func _ready() -> void:
	
	angular_velocity = vel_angular_base


func crear(pos : Vector2, dir : Vector2, tamanio : float):
	
	position = pos
	#Calcular Masa, tamaño de sprite y de Colisionador
	mass *= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	#Radio = diametro / 2
	var radio : int = int ($Sprite.texture.get_size().x / 3 * tamanio)
	var forma_colision : CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	#Calcular velocidades
	linear_velocity = (vel_lineal_base * dir / tamanio) * aleatorizar_velocidad()
	angular_velocity = (vel_angular_base / tamanio) * aleatorizar_velocidad()
	#Calcular hitpoints
	hitpoints = hitpoints_base * tamanio


func destruir():
	
	$CollisionShape2D.set_deferred("disabled", true)
	Eventos.emit_signal("destruccion_meteorito", global_position)
	queue_free()


func recibir_danio(danio : float) -> void:
	
	hitpoints -= danio
	
	if hitpoints < 0.0:
		destruir()
	
	sfx_impacto.play()
	animaciones.play("impacto")


func aleatorizar_velocidad() -> float:
	
	randomize()
	return rand_range(1.1, 1.4)

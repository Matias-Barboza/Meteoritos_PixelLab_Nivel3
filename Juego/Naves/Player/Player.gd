class_name Player
extends RigidBody2D


enum ESTADO {
	SPAWNEANDO,
	VIVO,
	INVULNERABLE,
	MUERTO
}


#Atributos como export
export var potencia_motor : int = 30
export var potencia_rotacion : int = 270
export var estela_maxima : int = 150
export var hitpoints : float = 10


#Atributos
var empuje : Vector2 = Vector2.ZERO
var dir_rotacion : int = 0
var estado_actual  : int = ESTADO.SPAWNEANDO


#Atributos onready
onready var canion : Canion = $Canion
onready var rayo_laser : RayoLaser = $LaserBeam2D
onready var estela : Estela = $PuntoInicioEstela/Trail2D 
onready var sfx_motor : AudioStreamPlayer2D = $SFXMotor
onready var colisionador : CollisionShape2D = $CollisionShape2D
onready var sfx_hurt : AudioStreamPlayer = $SFXImpactoDanio
onready var escudo : Escudo = $Escudo


# Métodos
func _ready() -> void:
	controlador_estados(estado_actual)


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	
	apply_central_impulse(empuje.rotated(rotation))
	apply_torque_impulse(dir_rotacion * potencia_rotacion)


func _process(delta: float) -> void:
	
	if not esta_input_activo():
		return
	
	player_input()


func controlador_estados(nuevo_estado : int) -> void:
	
	match nuevo_estado:
		ESTADO.SPAWNEANDO:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
		ESTADO.VIVO:
			colisionador.set_deferred("disabled", false)
			canion.set_puede_disparar(true)
		ESTADO.INVULNERABLE:
			colisionador.set_deferred("disabled", true)
		ESTADO.MUERTO:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
			Eventos.emit_signal("nave_destruida", global_position, 3)
			queue_free()
		_:
			printerr("Error de estado")
	
	estado_actual = nuevo_estado

func player_input() -> void:
	
	#Empuje
	empuje = Vector2.ZERO
	
	if Input.is_action_pressed("mover_adelante"):
		empuje = Vector2(potencia_motor, 0)
	elif Input.is_action_pressed("mover_atras"):
		empuje = Vector2(-potencia_motor, 0)
	
	#Rotacion
	dir_rotacion = 0
	if Input.is_action_pressed("rotar_horario"):
		dir_rotacion += 1
	elif Input.is_action_pressed("rotar_antihorario"):
		dir_rotacion -= 1
	
	#Disparo
	if Input.is_action_pressed("disparo_principal"):
		canion.set_esta_disparando(true)
	
	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)


func esta_input_activo() -> bool:
	
	if estado_actual in [ESTADO.SPAWNEANDO, ESTADO.MUERTO]:
		return false
	
	return true

func _unhandled_input(event: InputEvent) -> void:
	
	if not esta_input_activo():
		return
	
	#Disparo rayo laser
	if event.is_action_pressed("disparo_laser"):
		rayo_laser.set_is_casting(true)
	
	if event.is_action_released("disparo_laser"):
		rayo_laser.set_is_casting(false) 
	
	#Activado estela
	if event.is_action_pressed("mover_adelante"):
		estela.set_max_points(estela_maxima)
		sfx_motor.sonido_on()
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
		sfx_motor.sonido_on()
	
	if event.is_action_released("mover_adelante") or event.is_action_released("mover_atras"):
		sfx_motor.sonido_off()
	
	#Activar escudo
	if event.is_action_pressed("activar_escudo") and not escudo.get_esta_activado():
		escudo.activar()


func destruir() -> void:
	
	controlador_estados(ESTADO.MUERTO)


func recibir_danio(danio : float):
	
	hitpoints -= danio
	sfx_hurt.play()
	
	if hitpoints < 0.0:
		destruir()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

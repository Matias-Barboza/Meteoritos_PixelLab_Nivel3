class_name Player
extends NaveBase

# Atributos como export
export var potencia_motor : int = 30
export var potencia_rotacion : int = 260
export var estela_maxima : int = 150


# Atributos
var empuje : Vector2 = Vector2.ZERO
var dir_rotacion : int = 0


# Atributos onready
onready var rayo_laser : RayoLaser = $LaserBeam2D setget, get_laser
onready var estela : Estela = $PuntoInicioEstela/Trail2D 
onready var sfx_motor : AudioStreamPlayer2D = $SFXMotor
onready var escudo : Escudo = $Escudo setget, get_escudo


# Metodos
func _ready() -> void:
	DatosJuego.set_player_actual(self)


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
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
	
	if event.is_action_released("mover_adelante") or event.is_action_released("mover_atras"):
		sfx_motor.sonido_off()
	
	#Activar escudo
	if event.is_action_pressed("activar_escudo") and not escudo.get_esta_activado():
		escudo.activar()


func player_input() -> void:
	
	#Empuje
	empuje = Vector2.ZERO
	
	if Input.is_action_just_released("pausa"):
		
		Eventos.emit_signal("estado_pausa_nivel", true)
	
	
	if Input.is_action_pressed("mover_adelante"):
		
		empuje = Vector2(potencia_motor, 0)
		sfx_motor.sonido_on()
	elif Input.is_action_pressed("mover_atras"):
		
		empuje = Vector2(-potencia_motor, 0)
		sfx_motor.sonido_on()
	
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


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	
	apply_central_impulse(empuje.rotated(rotation))
	apply_torque_impulse(dir_rotacion * potencia_rotacion)


func _process(_delta: float) -> void:
	
	if not esta_input_activo():
		
		return
	
	player_input()


func desactivar_controles() -> void:
	
	controlador_estados(ESTADO.SPAWNEANDO)
	empuje = Vector2.ZERO
	sfx_motor.sonido_off()
	rayo_laser.set_is_casting(false)


# Getters y Setters
func get_laser() -> RayoLaser:
	
	return rayo_laser


func get_escudo() -> Escudo:
	
	return escudo


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if anim_name == "spawn":
		
		controlador_estados(ESTADO.VIVO)

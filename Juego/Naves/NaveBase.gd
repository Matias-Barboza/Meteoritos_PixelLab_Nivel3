#NaveBase.gd
class_name NaveBase
extends RigidBody2D

#Enums
enum ESTADO {
	SPAWNEANDO,
	VIVO,
	INVULNERABLE,
	MUERTO
}


#Atributos como export
export var hitpoints : float = 20
export var cantidad_explosiones : int


#Atributos
var estado_actual  : int = ESTADO.SPAWNEANDO


#Atributos onready
onready var colisionador : CollisionShape2D = $CollisionShape2D
onready var sfx_hurt : AudioStreamPlayer = $SFXImpactoDanio
onready var canion : Canion = $Canion
onready var barra_salud : ProgressBar = $BarraSalud


# Métodos
func _ready() -> void:
	
	barra_salud.set_valores(hitpoints)
	controlador_estados(estado_actual)


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
			Eventos.emit_signal("nave_destruida", self, global_position, cantidad_explosiones)
			queue_free()
		_:
			printerr("Error de estado")
	
	estado_actual = nuevo_estado


func destruir() -> void:
	
	controlador_estados(ESTADO.MUERTO)


func recibir_danio(danio : float)  -> void:
	
	hitpoints -= danio
	sfx_hurt.play()
	
	if hitpoints < 0.0:
		destruir()
	
	barra_salud.controlar_barra(hitpoints, true)

func _on_body_entered(body: Node) -> void:
	
	if body is Meteorito:
		body.destruir()
		destruir()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

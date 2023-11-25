class_name SectorMeteoritos
extends Node2D


# Atributos export
export var cantidad_meteoritos : int = 10
export var intervalo_spawn : float = 1.2 


# Atributos
var spawners : Array


# Metodos
func crear(posicion_global : Vector2, cantidad_meteoritos_spawnear : int) -> void:
	
	global_position = posicion_global
	cantidad_meteoritos = cantidad_meteoritos_spawnear


func _ready() -> void:
	
	$TimerSpawn.wait_time = intervalo_spawn
	
	almacenar_spawners()
	conectar_seniales_detectores()


func almacenar_spawners() -> void:
	
	for spawner in $SpawnersMeteorito.get_children():
		
		spawners.append(spawner)


func conectar_seniales_detectores() -> void:
	
	for detector in $DetectorFueraZona.get_children():
		
		detector.connect("body_entered", self, "_on_body_entered")


func spawner_aleatorio() -> int:
	
	randomize()
	return randi() % spawners.size()


#Señales internas
func _on_TimerSpawn_timeout() -> void:
	
	if cantidad_meteoritos == 0:
		
		$TimerSpawn.stop()
		return
	
	spawners[spawner_aleatorio()].spawnear_meteorito()
	cantidad_meteoritos -= 1


func _on_body_entered(body : Node) -> void:
	
	body.set_esta_en_sector(false)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if anim_name == "advertencia":
		
		$TimerSpawn.start()

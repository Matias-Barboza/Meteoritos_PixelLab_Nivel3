class_name Nivel
extends Node2D


#Atributos export
export var explosion : PackedScene = null
export var meteorito : PackedScene = null
export var explosion_meteorito : PackedScene = null
export var sector_meteoritos : PackedScene = null
export var tiempo_transicion_camara : float = 1


#Atributos onready
onready var contenedor_proyectiles : Node
onready var contenedor_meteoritos : Node
onready var contenedor_sectores_meteoritos : Node
onready var camara_nivel : Camera2D = $CamaraNivel


#Métodos
func _ready() -> void:
	
	conectar_seniales()
	crear_contenedores()


func conectar_seniales() -> void:
	
	Eventos.connect("disparo", self, "_on_disparo")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("spawn_meteorito", self, "_on_spawn_meteoritos")
	Eventos.connect("destruccion_meteorito", self, "_on_destruccion_meteorito")
	Eventos.connect("nave_en_sector_peligro", self , "_on_nave_en_sector_peligro")


func crear_contenedores() -> void:
	
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child(contenedor_meteoritos)
	
	contenedor_sectores_meteoritos = Node.new()
	contenedor_sectores_meteoritos.name = "contenedorSectoresMeteoritos"
	add_child(contenedor_sectores_meteoritos)


func crear_sector_meteoritos(centro_camara : Vector2, num_peligros : int) -> void:
	
	var new_sector_meteoritos : SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, num_peligros)
	camara_nivel.global_position = centro_camara
	contenedor_sectores_meteoritos.add_child(new_sector_meteoritos)
	transicion_camaras(
		$Player/CamaraPlayer.global_position,
		camara_nivel.global_position,
		camara_nivel
	)


func _on_disparo(proyectil : Proyectil) -> void:
	
	contenedor_proyectiles.add_child(proyectil)


func transicion_camaras(desde : Vector2, hasta : Vector2 , camara_actual : Camera2D) -> void:
	
	$TweenCamara.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo_transicion_camara,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	$TweenCamara.start()


func _on_nave_destruida(posicion : Vector2 , cantidad_explosiones) -> void:
	
	for _i in range(cantidad_explosiones):
		var new_explosion = explosion.instance()
		new_explosion.global_position = posicion
		add_child(new_explosion)
		yield(get_tree().create_timer(0.6), "timeout")


func _on_spawn_meteoritos(pos_spawn : Vector2, dir_meteorito : Vector2, tamanio : float) -> void:
	
	var new_meteorito : Meteorito = meteorito.instance()
	new_meteorito.crear(pos_spawn, dir_meteorito, tamanio)
	contenedor_meteoritos.add_child(new_meteorito)


func _on_destruccion_meteorito(posicion : Vector2) -> void:
	
	var new_explosion_meteorito : ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion_meteorito.global_position = posicion
	add_child(new_explosion_meteorito)


func _on_nave_en_sector_peligro(centro_camara : Vector2, tipo_peligro : String,
	num_peligros : int) -> void:
	
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_camara, num_peligros)
	elif tipo_peligro == "Enemigo":
		pass

class_name Nivel
extends Node2D


#Atributos export
export var explosion : PackedScene = null
export var meteorito : PackedScene = null
export var enemigo_interceptor : PackedScene = null
export var explosion_meteorito : PackedScene = null
export var sector_meteoritos : PackedScene = null
export var tiempo_transicion_camara : float = 1


#Atributos 
var cantidad_meteoritos : int 
var player : Player = null


#Atributos onready
onready var contenedor_proyectiles : Node
onready var contenedor_meteoritos : Node
onready var contenedor_enemigos : Node
onready var contenedor_sectores_meteoritos : Node
onready var camara_nivel : Camera2D = $CamaraNivel
onready var camara_player : Camera2D = $Player/CamaraPlayer
#onready var player : Player = $Player
onready var tween_camara : Tween = $TweenCamara


#Métodos
func _ready() -> void:
	
	player = DatosJuego.get_player_actual()
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
	
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "contenedorEnemigos"
	add_child(contenedor_enemigos)


func crear_sector_meteoritos(centro_camara : Vector2, num_peligros : int) -> void:
	
	cantidad_meteoritos = num_peligros
	var new_sector_meteoritos : SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, num_peligros)
	camara_nivel.global_position = centro_camara
	contenedor_sectores_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = camara_player.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		camara_player.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
	)


func crear_sector_enemigos(num_enemigos : int) -> void:
	
	for i in range(num_enemigos):
		var new_interceptor : EnemigoInterceptor = enemigo_interceptor.instance()
		var spawn_pos : Vector2 = crear_posicion_aleatoria(1000.0, 800.0)
		new_interceptor.global_position = player.global_position + spawn_pos
		contenedor_enemigos.add_child(new_interceptor)


func _on_disparo(proyectil : Proyectil) -> void:
	
	contenedor_proyectiles.add_child(proyectil)


func transicion_camaras(desde : Vector2, hasta : Vector2 , camara_actual : Camera2D, _tiempo_transicion : float) -> void:
	
	tween_camara.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo_transicion_camara,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	tween_camara.start()


func restar_cantidad_meteoritos() -> void:
	
	cantidad_meteoritos -= 1
	
	if cantidad_meteoritos == 0:
		contenedor_sectores_meteoritos.get_child(0).queue_free()
		camara_player.set_puede_hacer_zoom(true)
		var zoom_actual = camara_player.zoom
		camara_player.zoom = camara_nivel.zoom
		camara_player.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camaras(
			camara_nivel.global_position,
			camara_player.global_position,
			camara_player,
			tiempo_transicion_camara * 0.10
			)


func crear_posicion_aleatoria(rango_horizontal : float, rango_vertical : float) -> Vector2:
	
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	
	return Vector2(rand_x, rand_y)


func _on_nave_destruida(nave : Player,posicion : Vector2 , cantidad_explosiones) -> void:
	
	if nave is Player:
		transicion_camaras(
			posicion,
			posicion + crear_posicion_aleatoria(-200, 200),
			camara_nivel,
			tiempo_transicion_camara
		)
	
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
	restar_cantidad_meteoritos()


func _on_nave_en_sector_peligro(centro_camara : Vector2, tipo_peligro : String,
	num_peligros : int) -> void:
	
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_camara, num_peligros)
	elif tipo_peligro == "Enemigo":
		crear_sector_enemigos(num_peligros)


func _on_TweenCamara_tween_completed(object: Object, _key: NodePath) -> void:
	
	if object.name == "CamaraPlayer":
		object.global_position = player.global_position

class_name Proyectil
extends Area2D

#Atributos
var velocidad : Vector2 = Vector2.ZERO
var danio : float


func crear(pos : Vector2, dir: float, vel : float, danio_proyectil : int) -> void:
	
	position = pos 
	rotation = dir
	velocidad = Vector2(vel, 0).rotated(dir)
	danio = danio_proyectil


func _physics_process(delta: float) -> void:
	
	position += velocidad * delta


func _on_VisibilityNotifier2D_screen_exited() -> void:
	
	queue_free()


func _on_Proyectil_area_entered(area: Area2D) -> void:
	
	daniar(area)


func _on_Proyectil_body_entered(body: Node) -> void:
	
	daniar(body)


func daniar(cuerpo : CollisionObject2D):
	
	if cuerpo.has_method("recibir_danio"):
		cuerpo.recibir_danio(danio)
	
	queue_free()

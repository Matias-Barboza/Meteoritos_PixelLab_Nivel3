class_name EnemigoDummy
extends Node2D


#Atributos
export var hitpoints : float = 10


func _process(_delta: float) -> void:
	
	$Canion.set_esta_disparando(true)


func _on_Area2D_body_entered(body: Node) -> void:
	
	if body is Player:
		body.destruir()


func recibir_danio(danio : float):
	
	hitpoints -= danio
	
	if hitpoints < 0.0:
		queue_free()

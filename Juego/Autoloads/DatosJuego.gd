extends Node


# Atributos
var player_actual : Player = null setget set_player_actual, get_player_actual


# Metodos
func _ready() -> void:
	
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")


func _on_nave_destruida(nave : NaveBase, _posicion : Vector2, _explosiones : int) -> void:
	
	if nave is Player:
		
		player_actual = null 


#Setters y getters
func set_player_actual(player : Player) -> void:
	
	player_actual = player


func get_player_actual() -> Player:
	
	return player_actual

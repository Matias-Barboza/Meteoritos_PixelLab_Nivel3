class_name ExplosionMeteorito
extends Node2D


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	queue_free()

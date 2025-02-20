extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var invert_controls: bool = false

func _physics_process(_delta: float) -> void:
	if invert_controls:
		get_input_inverted()
	else:
		get_input()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

func get_input_inverted():
	var input_direction = Input.get_vector("right", "left", "up", "down")
	velocity = input_direction * SPEED

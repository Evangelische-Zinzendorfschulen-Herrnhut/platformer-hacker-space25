extends CharacterBody2D

const GRAVITY: float = 8.1
const SPEED: int = 50
const JUMP_POWER: int = -150

@export var movment_on = true

func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	movment()

func movment():
	if movment_on == true:
		if Input.is_action_pressed("left"):
			velocity.x = -SPEED
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.flip_h = true
		elif Input.is_action_pressed("right"):
			velocity.x = SPEED
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.flip_h = false
		else:
			velocity.x = 0
			$AnimatedSprite2D.play("idle")
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y += JUMP_POWER
	
			velocity.y += GRAVITY
	
			move_and_slide()

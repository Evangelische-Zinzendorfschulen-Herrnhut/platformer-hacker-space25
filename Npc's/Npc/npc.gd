extends Node2D

@export var can_talk = false
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func _process(delta):
	if can_talk and Input.is_action_just_pressed("e"):
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'spieler':
		can_talk = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'spieler':
		can_talk = true

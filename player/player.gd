
extends CharacterBody2D

# --- Tuning-Parameter ---
@export var gravity: float = 1800.0        # Pixel/s^2
@export var move_speed: float = 260.0      # Pixel/s
@export var jump_speed: float = 150.0      # Anfangs-Sprunggeschwindigkeit (nach oben)
@export var max_air_jumps: int = 1         # 1 = Double Jump, 2 = Triple Jump, usw.

# Optional: Komfort-Funktionen
@export var coyote_time: float = 0.12      # Sek., in denen Sprung noch zählt, nachdem Boden verlassen
@export var jump_buffer_time: float = 0.12 # Sek., in denen ein "zu früh" gedrückter Sprung zwischengespeichert wird
@export var variable_jump_factor: float = 0.55 # Wie stark der Sprung bei frühem Loslassen gekürzt wird (0–1)

# --- Laufzeit-Variablen ---
var air_jumps_left: int = max_air_jumps
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	handle_horizontal_move(delta)
	apply_gravity(delta)
	read_jump_input()
	try_jump()
	apply_variable_jump(delta)

	# Bewegung anwenden
	move_and_slide()

	# Boden-Logik / Reset der Sprünge
	if is_on_floor():
		coyote_timer = coyote_time                      # Zeitfenster nach Boden verlassen
		air_jumps_left = max_air_jumps                  # In der Luft verfügbare Sprünge zurücksetzen
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# Jump-Buffer abbauen
	jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

# --- Bewegungssteuerung ---
func handle_horizontal_move(_delta: float) -> void:
	var dir := Input.get_action_strength("right") - Input.get_action_strength("left")
	if velocity.x > 0:
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.play("idle")
		
	velocity.x = dir * move_speed

# --- Schwerkraft ---
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# auf dem Boden minimal stabilisieren
		if velocity.y > 0.0:
			velocity.y = 0.0

# --- Eingaben lesen ---
func read_jump_input() -> void:
	# Jump gedrückt -> Buffer setzen
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

# --- Sprung versuchen ---
func try_jump() -> void:
	var can_ground_jump := is_on_floor() or coyote_timer > 0.0
	var can_air_jump := (not can_ground_jump) and air_jumps_left > 0

	if jump_buffer_timer > 0.0:
		if can_ground_jump:
			do_jump()
			jump_buffer_timer = 0.0
		elif can_air_jump:
			do_jump()
			air_jumps_left -= 1
			jump_buffer_timer = 0.0

# --- Sprung ausführen ---
func do_jump() -> void:
	velocity.y = -jump_speed
	# Beim Sprung endet Coyote Time
	coyote_timer = 0.0

# --- Variabler Sprung (frühes Loslassen verringert Höhe) ---
func apply_variable_jump(_delta: float) -> void:
	# Wenn Sprungtaste losgelassen und wir noch aufwärts fliegen, kürzen
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= variable_jump_factor

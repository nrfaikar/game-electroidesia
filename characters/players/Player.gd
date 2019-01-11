extends KinematicBody

export var character_name: String = ""
export var hit_point: float = 0.0
export var mana_point: float = 0.0

const SPEED = 15
const GRAVITATION = -9.8 * 2

var velocity = Vector3()
var is_attacking = false

onready var camera = get_node("/root").get_camera()

func _ready() -> void:
	GameManager.set_character(character_name, hit_point, mana_point)

func _physics_process(delta: float) -> void:
	if not GameManager.is_interrupted:
		process_movement(delta)
	else:
		# Play character idle animation
		# if current_animation != "idle"
		if $AnimationPlayer.current_animation != "idle" and not is_attacking:
			$AnimationPlayer.play("idle")
			
			# Reset velocity
			velocity = Vector3()

func process_movement(delta: float) -> void:
	var direction = Vector3()
	var camera_xform = camera.get_global_transform()
	var is_moving = false

	# Get movement input from player
	if Input.is_action_pressed("movement_forward"):
		direction -= camera_xform.basis[2]
		is_moving = true
	if Input.is_action_pressed("movement_backward"):
		direction += camera_xform.basis[2]
		is_moving = true
	if Input.is_action_pressed("movement_right"):
		direction += camera_xform.basis[0]
		is_moving = true
	if Input.is_action_pressed("movement_left"):
		direction -= camera_xform.basis[0]
		is_moving = true
	
	direction.y = 0
	direction = direction.normalized()
	
	# Make character interacts with static "gravitation"
	velocity.y = GRAVITATION
	
	# Make smooth character movement
	velocity = velocity.linear_interpolate(direction * SPEED, 10 * delta)
	
	# Make movement to character
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(70))
	
	if is_moving:
		# If character is moving then
		# make rotation to player's face
		rotation.y = atan2(velocity.x, velocity.z)
		
		# Play character run animation
		# if current_animation != "run"
		if $AnimationPlayer.current_animation != "run":
			$AnimationPlayer.play("run")
	else:
		# Play character idle animation
		# if current_animation != "idle"
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")

func attack(enemy_node: Node) -> void:
	var attack_point = get_node("Skeleton/Weapon").weapon_physical_attack
	
	# Add damage to enemy
	is_attacking = true
	$AnimationPlayer.play("slash", -1, 2)
	enemy_node.attacked(attack_point)
	
	# Show damage
	yield($AnimationPlayer, "animation_finished")
	var damage_text = load("res://game_ui/hud/DamageText.tscn").instance()
	var screen_position = get_node("/root").get_camera().unproject_position(enemy_node.translation)
	damage_text.text = str(attack_point)
	damage_text.rect_position = Vector2(screen_position.x, screen_position.y)
	get_node("/root/HUD").add_child(damage_text)
	damage_text.show()
	print("serang")

func on_attack_finished() -> void:
	is_attacking = false
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

var gravity = ProjectSettings.get_setting("physics/3D/default_gravity")

@onready var camera = $Camera3D
@onready var flashlight = $Camera3D/Flashlight
@onready var interact_ray = $Camera3D/RayCast3D
@onready var hold_position = $Camera3D/HoldPosition

var held_object = null

func _ready():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _unhandled_input(event):
		if event is InputEventMouseMotion:
				rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
				camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
				camera.rotate_x = clamp(camera.rototation.x, deg_to_rad(-90), deg_to_rad(90))
				
		if Input.is_action_just_pressed("toggle_flashlight"):
				flashlight.visible = !flashlight.visible
		# Interaction button logic
		if Input.is_action_just_pressed("interact"):
				if held_object == null:
						pick_up()
				else:
						drop()
						
# Custom function to pick up items
func pick_up():
		if interact_ray.is_colliding():
				var target = interact_ray.get_collider()
				#Only pick up physics objects
				if target is RigidBody3D:
						held_object = target	
						held_object.freeze = true # Stops gravity while holding
						
# Custom function to drop items
func drop():
		if held_object != null:
				held_object.freeze = false # Truns gravity back on
				held_object = null
				
func _physics_process(delta):
		if not is_on_floor():
				velocity.y -= gravity * delta
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				
		var input_dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
		else:
				velocity.x = move_toward(velocity.x, 0,SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				
		move_and_slide()
		
		# Smoothly float the held object to the HoldPosition marker
		if held_object != null:
				var target_pos = hold_position.global_position
				held_object.global_position = held_object.global_position.lerp(target_pos, 10 * delta)						
								
				
				
				
	   										
				
												
									

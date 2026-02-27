extends Node2D

@onready var body: RigidBody2D = %Body
@onready var thigh_l: RigidBody2D = %ThighL
@onready var shin_l: RigidBody2D = %ShinL
@onready var thigh_r: RigidBody2D = %ThighR
@onready var shin_r: RigidBody2D = %ShinR
@onready var anchor_l: PinJoint2D = %FootAnchorL
@onready var anchor_r: PinJoint2D = %FootAnchorR
@onready var foot_l: Marker2D = %FootL
@onready var foot_r: Marker2D = %FootR
@onready var ray_l: RayCast2D = %RayCastL
@onready var ray_r: RayCast2D = %RayCastR

# Tuning for DLL feel
@export var swing_torque: float = 20000.0
@export var balance_torque: float = 3000.0
@export var joint_lock_strength: float = 1.0 # Max rigidity

var is_left_standing: bool = false

func _ready() -> void:
	# Ignore collisions between all player parts
	var parts = [body, thigh_l, shin_l, thigh_r, shin_r]
	for p1 in parts:
		for p2 in parts:
			if p1 != p2:
				p1.add_collision_exception_with(p2)
	
	# Initial state
	_setup_standing_leg(false)
 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") or (event is InputEventMouseButton and event.pressed):
		_try_switch_legs()

func _try_switch_legs() -> void:
	# Only switch if the swinging leg is touching the ground
	var can_switch = false
	if is_left_standing:
		if ray_r.is_colliding(): can_switch = true
	else:
		if ray_l.is_colliding(): can_switch = true
	
	if can_switch:
		is_left_standing = !is_left_standing
		_setup_standing_leg(is_left_standing)

func _setup_standing_leg(left: bool) -> void:
	if left:
		_anchor_to_ground(anchor_l, shin_l, ray_l)
		_unanchor(anchor_r)
		# Immediate straightening of the new standing leg
		shin_l.rotation = thigh_l.rotation
		shin_l.angular_velocity = thigh_l.angular_velocity
	else:
		_anchor_to_ground(anchor_r, shin_r, ray_r)
		_unanchor(anchor_l)
		shin_r.rotation = thigh_r.rotation
		shin_r.angular_velocity = thigh_r.angular_velocity

func _anchor_to_ground(anchor: PinJoint2D, shin: RigidBody2D, ray: RayCast2D) -> void:
	anchor.node_a = NodePath("")
	if ray.is_colliding():
		anchor.global_position = ray.get_collision_point()
	else:
		anchor.global_position = ray.global_position
	anchor.node_a = shin.get_path()

func _unanchor(anchor: PinJoint2D) -> void:
	anchor.node_a = NodePath("")

func _physics_process(_delta: float) -> void:
	# Body balance torque - keeps the square-ish body relatively upright
	body.apply_torque(-body.rotation * balance_torque)
	
	if is_left_standing:
		_apply_leg_physics(thigh_l, shin_l, thigh_r, shin_r)
	else:
		_apply_leg_physics(thigh_r, shin_r, thigh_l, shin_l)
	
	queue_redraw()

func _apply_leg_physics(st_thigh: RigidBody2D, st_shin: RigidBody2D, sw_thigh: RigidBody2D, sw_shin: RigidBody2D) -> void:
	# 1. Standing Leg (st_thigh/shin) -> Rigid Pole
	# We use extremely high torque to fight any bending at the knee
	var angle_diff = st_thigh.rotation - st_shin.rotation
	var st_correction = angle_diff * 100000.0 # Extreme stiffness
	st_thigh.apply_torque(-st_correction)
	st_shin.apply_torque(st_correction)
	
	# 2. Swinging Leg (sw_thigh/shin) -> Smooth Pendulum
	# Swing the thigh forward based on body tilt and momentum
	sw_thigh.apply_torque(swing_torque)
	
	# Let the shin bend slightly but keep it "ready"
	var sw_knee_bend = sw_thigh.rotation - sw_shin.rotation
	sw_shin.apply_torque(sw_knee_bend * 5000.0) # Soft spring for the knee

func _draw() -> void:
	# Debug visualizations
	if anchor_l.node_a != NodePath(""):
		draw_circle(anchor_l.global_position - global_position, 6.0, Color.CYAN)
	if anchor_r.node_a != NodePath(""):
		draw_circle(anchor_r.global_position - global_position, 6.0, Color.GREEN)
	
	# Draw line for target ground if RayCast hits
	if ray_l.is_colliding():
		draw_line(ray_l.global_position - global_position, ray_l.get_collision_point() - global_position, Color.WHITE, 1.0)
	if ray_r.is_colliding():
		draw_line(ray_r.global_position - global_position, ray_r.get_collision_point() - global_position, Color.WHITE, 1.0)

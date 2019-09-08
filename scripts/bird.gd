extends RigidBody2D
class_name B_Bee

onready var state setget set_state, get_state
var prev_state: int

var speed = 50

const STATE_FLYING   = 0
const STATE_FLAPPING = 1
const STATE_HIT      = 2
const STATE_GROUNDED = 3

signal state_changed

func _ready() -> void:
  state = FlyingState.new(self)
  add_to_group(game.GROUP_BIRDS)
  connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
  state.update(delta)

func _input(event: InputEvent) -> void:
  state.input(event)

func _unhandled_input(event: InputEvent) -> void:
  state.unhandled_input(event)

func _on_body_entered(other_body: Node) -> void:
  state.on_body_entered(other_body)

func set_state(new_state: int) -> void:
  state.exit()
  prev_state = get_state()
  
  if   new_state == STATE_FLYING  : state = FlyingState.new(self)
  elif new_state == STATE_FLAPPING: state = FlappingState.new(self)
  elif new_state == STATE_HIT     : state = HitState.new(self)
  elif new_state == STATE_GROUNDED: state = GroundedState.new(self)
  
  emit_signal("state_changed", self)

func get_state() -> int:
  if   state is FlyingState  : return STATE_FLYING
  elif state is FlappingState: return STATE_FLAPPING
  elif state is HitState     : return STATE_HIT
  elif state is GroundedState: return STATE_GROUNDED
  
  return -1

class BeeState:
  var bee
  
  func _init(bee: B_Bee) -> void:
    self.bee = bee
    bee.get_node("Sprite/AnimationPlayer").play("Idle")
  
  func update(delta: float) -> void:
    pass

  func input(event: InputEvent) -> void:
    pass

  func unhandled_input(event: InputEvent) -> void:
    pass
  
  func on_body_entered(other_body: Node):
    pass
  
  func exit() -> void:
    pass

class FlyingState extends BeeState:
  var prev_gravity_scale
  
  func _init(bee: B_Bee).(bee) -> void:
    bee.linear_velocity.x = bee.speed
    prev_gravity_scale = bee.gravity_scale
    bee.gravity_scale = 0
  
  func exit() -> void:
    bee.gravity_scale = prev_gravity_scale
    bee.get_node("Sprite/AnimationPlayer").stop()
    bee.get_node("Sprite").position = Vector2(0, 0)

class FlappingState extends BeeState:
  func _init(bee: B_Bee).(bee) -> void:
    bee.linear_velocity.x = bee.speed
    flap()
  
  func update(delta: float) -> void:
    if bee.rotation_degrees < -30:
      bee.rotation_degrees = -30
      bee.angular_velocity = 0
    
    if bee.linear_velocity.y > 0:
      bee.angular_velocity = 1.5
  
  func input(event: InputEvent) -> void:
    if event.is_action_pressed("flap"):
      flap()

  func unhandled_input(event: InputEvent) -> void:
    if (not event is InputEventMouseButton) or !event.pressed or event.is_echo():
      return
    
    if event.button_index == BUTTON_LEFT:
      flap()
  
  func on_body_entered(other_body: Node):
    if   other_body.is_in_group(game.GROUP_PIPES)  : bee.state = bee.STATE_HIT
    elif other_body.is_in_group(game.GROUP_GROUNDS): bee.state = bee.STATE_GROUNDED
  
  func flap() -> void:
    bee.linear_velocity.y = -150
    bee.angular_velocity = -3
    audio_player.get_node("sfx_buzz").play()

class HitState extends BeeState:
  func _init(bee: B_Bee).(bee) -> void:
    bee.linear_velocity = Vector2(0,0)
    bee.angular_velocity = 2
    
    var other_body = bee.get_colliding_bodies()[0]
    bee.add_collision_exception_with(other_body)
    
    audio_player.get_node("sfx_dead").play()
  
  func on_body_entered(other_body: Node):
    if other_body.is_in_group(game.GROUP_GROUNDS):
      bee.state = bee.STATE_GROUNDED

class GroundedState extends BeeState:
  func _init(bee: B_Bee).(bee) -> void:
    bee.linear_velocity = Vector2(0,0)
    bee.angular_velocity = 0
    
    if bee.prev_state != bee.STATE_HIT:
      audio_player.get_node("sfx_dead").play()
extends Camera2D
class_name QCamera

onready var bee: B_Bee = utils.get_main_node().get_node("bird")

func _physics_process(delta: float) -> void:
  position.x = bee.position.x

func get_total_position() -> Vector2:
  return position + offset
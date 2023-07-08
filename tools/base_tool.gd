extends Control
class_name BaseTool

func draw_to_canvas(xy: Vector2, canvas: Image):
	pass

func preview_on_canvas(xy: Vector2):
	pass

func get_control_panel() -> Control:
	return null

func serialize():
	pass

func deserialize():
	pass

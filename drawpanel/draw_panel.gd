extends Control

# Drawing and canvas
@onready var canvas: TextureRect = $GridContainer/Canvas
var needs_redraw: bool = false
var gpu_texture: ImageTexture
var cpu_texture: Image

# Inputs
var mouse_down_previous_frame: bool = false
var mouse_down: bool = false
var mouse_just_pressed: bool = false
var mouse_just_released: bool = false
var mouse_position_previous_frame: Vector2 = Vector2(-1, -1)  # Relative to canvas.

# Placeholder for general ticket
@export var interpolation_steps_per_pixel: float = 2.0  # How many times do we want to draw per pixel?
var active_tool: BaseTool

# Called when the node enters the scene tree for the first time.
func _ready():
	self.canvas.resized.connect(_on_canvas_resized)
	#canvas.custom_minimum_size = Vector2i(768, 768);
	# Allocate a texture that's the same size as the default canvas.
	self.cpu_texture = Image.new()
	var white = PackedByteArray()
	for y in range(0, canvas.size.y):
		for x in range(0, canvas.size.x):
			for channel in range(0, 4):
				white.append(255)
	self.cpu_texture.set_data(self.canvas.size.x, self.canvas.size.y, false, Image.FORMAT_RGBA8, white)
	#ram_texture.resize(canvas.size.x, canvas.size.y, Image.INTERPOLATE_TRILINEAR)
	self.gpu_texture = ImageTexture.create_from_image(self.cpu_texture)
	self.canvas.texture = gpu_texture
	
	#var image = Image.load_from_file("res://icon.svg")
	#var texture = ImageTexture.create_from_image(image)
	#$Sprite2D.texture = texture
	
	# Prefer to load:
	#var texture = load("res://icon.svg")
	#$Sprite2D.texture = texture
	
	#var texture = load("res://icon.svg")
	#var image: Image = texture.get_image()
	
	# Use GPU tooling to draw?
	#var rd := RenderingServer.create_local_rendering_device()
	
	self._activate_marker_tool()

func _activate_marker_tool():
	self.active_tool = MarkerTool.new()
	get_tree().root.add_child.call_deferred(self.active_tool)
	self.active_tool.visible = false

func _on_canvas_resized(x: int, y: int):
	print("Canvas resized")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update status of mouse presses.
	self.mouse_just_pressed = self.mouse_down and not self.mouse_down_previous_frame
	self.mouse_just_released = not self.mouse_down and self.mouse_down_previous_frame
	
	if self.mouse_down:
		self.do_tool_operation()
	
	if self.needs_redraw:
		self.needs_redraw = false
		self.gpu_texture.update(self.cpu_texture)
	
	self.mouse_down_previous_frame = self.mouse_down
	self.mouse_position_previous_frame = self.canvas.get_local_mouse_position()

func clear_canvas(clear_color: Color = Color.WHITE):
	self.cpu_texture.fill_rect(Rect2i(0, 0, self.cpu_texture.get_width(), self.cpu_texture.get_height()), clear_color)
	self.needs_redraw = true

func _draw():
	if self.active_tool != null:
		self.active_tool.preview_on_canvas(self.canvas.get_local_mouse_position())

func do_tool_operation():
	#self.cpu_texture.blend_rect()
	#self.cpu_texture.set_pixelv(self.canvas.get_local_mouse_position(), Color(0, 0, 0, 1.0))
	if self.active_tool != null:
		if self.interpolation_steps_per_pixel < 1e-6 or not self.mouse_down_previous_frame or self.mouse_position_previous_frame.x < 0:
			self.active_tool.draw_to_canvas(self.canvas.get_local_mouse_position(), self.cpu_texture)
		else:
			# Compute the distance from the start to the end and interpolate by this many steps.
			var drag_distance = (self.mouse_position_previous_frame - self.canvas.get_local_mouse_position()).length()
			var steps = max(1, int(ceil(drag_distance * self.interpolation_steps_per_pixel)))
			for i in range(0, steps+1):
				var interpolated_x = lerpf(self.mouse_position_previous_frame.x, self.canvas.get_local_mouse_position().x, float(i) / float(steps))
				var interpolated_y = lerpf(self.mouse_position_previous_frame.y, self.canvas.get_local_mouse_position().y, float(i) / float(steps))
				self.active_tool.draw_to_canvas(Vector2(interpolated_x, interpolated_y), self.cpu_texture)
		self.needs_redraw = true

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.mouse_down = event.pressed
			#print("Event mouse click/unclick at: ", event.position)
			#print("Global mouse click:", get_global_mouse_position())
			#print("Local mouse click:", get_local_mouse_position())
			#print("Canvas mouse click:", self.canvas.get_local_mouse_position())
	elif event is InputEventMouseMotion:
		pass
		#print("Mouse Motion at: ", event.position)
	#print("Viewport Resolution is: ", get_viewport_rect().size)

extends BaseTool
class_name MarkerTool

@export var radius: float = 32.0
@export var flow: float = 1.0
@export var color: Color = Color.BLACK
@export var falloff: float = 2.0
@export var sharpness: float = 0.01

# The image is what's drawn from the tool to the canvas.
var image: Image

# For showing and adjusting.
@onready var display: TextureRect = $CenterContainer/TextureRect  # TODO: Why is this not getting allocated?

func _ready():
	self.set_brush_size.call_deferred(self.radius)

func refresh_controls():
	# Copy the contents to the controls.
	if self.display == null:
		self.display = TextureRect.new()
		#$CenterContainer.add_child(self.display)
	if self.display.texture == null:
		self.display.texture = ImageTexture.create_from_image(self.image)
	else:
		self.display.texture.update(self.image)

func set_brush_size(new_radius: float):
	self.radius = new_radius
	self.image = Image.new()
	var pixel_data = PackedByteArray()
	for y in range(0, 2*int(ceil(self.radius))):
		for x in range(0, 2*int(ceil(self.radius))):
			var x_prime = (x - self.radius)/radius
			var y_prime = (y - self.radius)/radius
			var intensity = pow(((x_prime*x_prime + y_prime*y_prime)/sharpness), -falloff)
			pixel_data.append(color.r8)
			pixel_data.append(color.g8)
			pixel_data.append(color.b8)
			pixel_data.append(clamp(255*intensity, 0, 255))
	self.image.set_data(2*int(ceil(self.radius)), 2*int(ceil(self.radius)), false, Image.FORMAT_RGBA8, pixel_data)
	self.refresh_controls()

func draw_to_canvas(xy: Vector2, canvas: Image):
	if self.image == null:
		return  # Not initialized.
	# Draw centered.
	var x = xy.x - (self.image.get_width()*0.5)
	var y = xy.y - (self.image.get_height()*0.5)
	canvas.blend_rect(self.image, Rect2i(0, 0, self.image.get_width(), self.image.get_height()), Vector2i(x, y))

func preview_on_canvas(xy: Vector2):
	if self.image == null:
		return  # Not initialized.
	var x = xy.x - (self.image.get_width() * 0.5)
	var y = xy.y - (self.image.get_height() * 0.5)
	draw_circle(Vector2i(x, y), self.radius, Color(1.0, 0, 1.0, 0.4))

func get_control_panel() -> Control:
	return self

func serialize():
	pass

func deserialize():
	pass

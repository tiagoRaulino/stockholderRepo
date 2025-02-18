extends ColorRect
class_name StockBox

@export var price: int = 0
@export var width: float = 100
@export var rect_color: Color = Color.WHITE

var label: Label  # Reference to the text label

func _ready():
	set_size(Vector2(width, 40))  # Set box width
	color = self.color  # Apply color

	# Find the Label node
	label = $ValueLabel
	update_label()

func setup(new_price, new_width, new_color):
	price = new_price
	width = new_width
	color = new_color

	set_size(Vector2(width, 40))  # Adjust size
	self.color = color  # Apply color
	update_label()

func update_label():
	if label:
		label.text = "R$"+str(price) # Display the price
		label.set_position(Vector2((width - label.size.x) / 2, 10))  # Center the text

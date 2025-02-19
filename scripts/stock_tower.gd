extends Node2D
class_name StockTower

var boxes: Array = []  
@export var max_height: int = 10  

func add_box(box: StockBox):
	if boxes.size() >= max_height:
		return  

	if box.get_parent():
		box.get_parent().remove_child(box)  

	boxes.append(box)
	add_child(box)

	# Position box on top of the stack
	var new_y = -40 * (boxes.size() - 1) - 40
	box.position = Vector2(-box.size.x / 2, new_y)

	# Check if the game is won after adding a box
	get_parent().move_count += 1
	get_parent().move_count_label.text = str(get_parent().move_count)
	get_parent().check_win()

func remove_top_box():
	if boxes.size() > 0:
		var box = boxes.pop_back()
		remove_child(box)  
		return box
	return null

# Increasing size order (thinner to wider)
func increase_size_order():
	if boxes.size() != max_height:
		return false  

	for i in range(1, boxes.size()):
		if boxes[i].width < boxes[i - 1].width:
			return false  
	return true

# Decreasing size order (wider to thinner)
func decrease_size_order():
	if boxes.size() != max_height:
		return false  

	for i in range(1, boxes.size()):
		if boxes[i].width > boxes[i - 1].width:
			return false  
	return true

# Increasing price order (cheapest to most expensive)
func increase_price_order():
	if boxes.size() != max_height:
		return false  

	for i in range(1, boxes.size()):
		if boxes[i].price < boxes[i - 1].price:
			return false  
	return true

# Decreasing price order (most expensive to cheapest)
func decrease_price_order():
	if boxes.size() != max_height:
		return false  

	for i in range(1, boxes.size()):
		if boxes[i].price > boxes[i - 1].price:
			return false  
	return true

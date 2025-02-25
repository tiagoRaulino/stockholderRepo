extends Node
class_name ScoringTree  # Allows this script to be used as a custom class

class ScoringNode:
	var left: ScoringNode = null
	var right: ScoringNode = null
	var score: int = 0  # Leaf nodes will hold the final score
	
	func _init(score_value = 0):
		self.score = score_value

var root: ScoringNode  # Declare the root node

func _init():
	# Level 1: Speed (0 = good, 1 = bad)
	root = ScoringNode.new()  # Root node (decision based on Speed)
	root.left = ScoringNode.new()  # Good Speed
	root.right = ScoringNode.new() # Bad Speed
	
	# Level 2: Amount of Movements (0 = good, 1 = bad)
	root.left.left = ScoringNode.new()  # Good Speed, Good Movements
	root.left.right = ScoringNode.new() # Good Speed, Bad Movements
	root.right.left = ScoringNode.new() # Bad Speed, Good Movements
	root.right.right = ScoringNode.new() # Bad Speed, Bad Movements
	
	# Level 3: Missed Stack (0 = good, 1 = bad)
	root.left.left.left = ScoringNode.new(100)  # Best Case (All 0s)
	root.left.left.right = ScoringNode.new(90)  # Missed stack only
	root.left.right.left = ScoringNode.new(85)  # Bad Movements only
	root.left.right.right = ScoringNode.new(75) # Bad Movements + Missed stack
	root.right.left.left = ScoringNode.new(70)  # Bad Speed only
	root.right.left.right = ScoringNode.new(60) # Bad Speed + Missed stack
	root.right.right.left = ScoringNode.new(50) # Bad Speed + Bad Movements
	root.right.right.right = ScoringNode.new(30) # Worst Case (All 1s)

func get_score(LevelStates: Array) -> int:
	var current = root
	
	if LevelStates[0] == 1:  # Bad Speed
		current = current.right
	else:  # Good Speed
		current = current.left
	
	if LevelStates[1] == 1:  # Bad Movements
		current = current.right
	else:  # Good Movements
		current = current.left
	
	if LevelStates[2] == 1:  # Missed Stack
		current = current.right
	else:  # Good Stack
		current = current.left
	
	return current.score  # Return the final score from the leaf node

extends Node
class_name LinkedNode

var value #coordinates, I think?
var priority: int
var next: LinkedNode #The next node on linked list

## When we createa a new LinkedNode, we will define the properties of the node. (Constructor Function)
## the '= null' means that when we create a new node and we only pass 2 parameters with no third value,
## then then nextNode will default to null
func _init(node_value: Vector2, node_priority: int, next_node: LinkedNode = null):
	value = node_value
	priority = node_priority
	next = next_node

## Setter functions
func set_value(new_value: Vector2):
	value = new_value

func set_priority(new_priority: int):
	priority = new_priority

func set_next(new_node: LinkedNode):
	next = new_node

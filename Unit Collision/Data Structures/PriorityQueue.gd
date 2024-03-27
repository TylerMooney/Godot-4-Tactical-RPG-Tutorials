## The way the priority queue works is that we only have access to the first element directly
## but each element in that queue is linked to the element that follows it, so we can traverse through
## the queue one by one.
## Our implementation will have these nodes sorted by priority value (from lowest priority to highest priority)
## Code is adapted from this link: https://www.geeksforgeeks.org/priority-queue-using-linked-list/
extends Node
class_name PriorityQueue

var front #front node of our linkedlist, what we are going to retrieve to access the list
var new_node #helper var
var temp #helper var

func _init():
	front = null

func is_empty():
	return front == null

## Inserts element into our queue
## Value: Cell we want to push into the queue
## Priority: The distance of the cell from our position
func push(value: Vector2, priority: int):
	if is_empty():
		front = LinkedNode.new(value, priority)
	elif front.priority > priority: #we do this since we want to find the shortest path from lowest to highest priority
		new_node = LinkedNode.new(value, priority, front) #insert current node as next node
		new_node.next = front
		front = new_node
	else: #front.priority < priority
		temp = front
		
		## We want to traverse through the queue until we find the right spot to put this node
		while temp.next:
			if priority <= temp.next.priority:
				break
			
			temp = temp.next
		
		new_node = LinkedNode.new(value, priority, temp.next)
		temp.next = new_node

## Way to get our node out of the queue
func pop():
	if is_empty():
		return
	else:
		temp = front
		front = front.next
		return temp

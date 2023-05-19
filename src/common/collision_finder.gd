## Find all collision shapes of a given mask within a specified search radius.
##
## The CollisionFinder is used to search for objects that contain a [CollisionObject2D]. In the 
## OpenRPG it serves as the cornerstone of the [Gameboard]/[Gamepiece] system, since objects 
## (gamepieces, terrain, etc.) are found dynamically by collision shape.
##
## [br][br]For example, to see if a given cell is occupied a CollisionFinder would be used to 
## [method search] for collision shapes at that cell's location.
##
## [br][br][b]Note:[/b] physics objects update on the physics 'tick' so changes in position often
## need a single frame before they may be found by [method search].
class_name CollisionFinder
extends RefCounted

## Cache the search parameters to quickly perform multiple searches.
var query_parameters: PhysicsShapeQueryParameters2D

# Cache the space state that will be queried.
var _space_state: PhysicsDirectSpaceState2D 


func _init(space_state: PhysicsDirectSpaceState2D, search_radius: float, collision_mask: int, 
		find_areas: = true) -> void:
	_space_state = space_state
	
	var query_shape: = CircleShape2D.new()
	query_shape.radius = search_radius
	
	query_parameters = PhysicsShapeQueryParameters2D.new()
	query_parameters.shape = query_shape
	query_parameters.collision_mask = collision_mask
	query_parameters.collide_with_areas = find_areas


## Find all collision shapes intersecting the query shape at position (in global coordinates).
##
## Please see [method PhysicsDirectSpaceState2D.intersect_shape] for possible return values.
## [br][br][b]Note:[/b] [code]position[/code] must be given in global coordinates.
func search(position: Vector2) -> Array[Dictionary]:
	# To find collision shapes we'll query the PhysicsDirectSpaceState2D (usually from the main
	# viewport's current World2D). Any intersecting collision shape matching the provided collision
	# mask will be included in the results.
	query_parameters.transform.origin = position
	
	return _space_state.intersect_shape(query_parameters)

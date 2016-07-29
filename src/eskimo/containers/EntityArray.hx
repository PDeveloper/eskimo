package eskimo.containers;

/**
 * ...
 * @author PDeveloper
 */

class EntityArray
{
	
	private var has_entities:Array<Bool>;
	public var entities:Array<Entity>;
	
	public var length(get, null):Int;
	
	public function new():Void
	{
		has_entities = [];
		entities = [];
	}
	
	public inline function push(e:Entity):Int
	{
		has_entities[e.id] = true;
		return entities.push(e);
	}
	
	public inline function remove(e:Entity):Bool
	{
		has_entities[e.id] = false;
		return entities.remove(e);
	}
	
	public inline function pop():Entity
	{
		var e = entities.pop();
		has_entities[e.id] = false;
		return e;
	}
	
	public inline function has(e:Entity):Bool
	{
		return has_entities[e.id];
	}
	
	public inline function iterator():Iterator<Entity>
	{
		return entities.iterator();
	}
	
	function get_length():Int 
	{
		return entities.length;
	}
	
}
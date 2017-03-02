package eskimo.containers;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

class EntityArray
{
	
	private var has_entities:Array<Bool>;
	public var entities:Array<Entity>;
	
	public var length(get, null):Int;
	private var _length:Int;
	
	public inline function new():Void
	{
		has_entities = [];
		entities = [];
	}
	
	public inline function get(index:Int):Entity
	{
		return entities[index];
	}
	
	public inline function push(e:Entity):Int
	{
		has_entities[e.id()] = true;
		
		if (entities.length > _length)
		{
			entities[_length++] = e;
			return _length;
		}
		
		entities.push(e);
		return ++_length;
	}
	
	public inline function remove(e:Entity):Bool
	{
		if (_length <= 0 || !has(e)) return false;
		
		//trace(entities);
		
		has_entities[e.id()] = false;
		var index = entities.indexOf(e);
		entities[index] = entities[--_length];
		
		//trace(entities);
		
		return true;
	}
	
	public inline function pop():Entity
	{
		var e = entities[--_length];
		has_entities[e.id()] = false;
		return e;
	}
	
	public inline function has(e:Entity):Bool
	{
		return has_entities[e.id()];
	}
	
	public inline function clear():Void
	{
		for (index in 0..._length) has_entities[entities[index].id()] = false;
		_length = 0;
	}
	
	private inline function get_length():Int 
	{
		return _length;
	}
	
	public inline function iterator():EntityArrayIterator
	{
		return new EntityArrayIterator(this);
	}
	
}

class EntityArrayIterator
{
	
	private var index:Int;
	private var array:EntityArray;
	
	public inline function new(array:EntityArray):Void
	{
		index = 0;
		this.array = array;
	}
	
	public inline function hasNext():Bool
	{
		return index < array.length;
	}
	
	public inline function next():Entity
	{
		return array.get(index++);
	}
	
}
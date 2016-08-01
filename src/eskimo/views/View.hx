package eskimo.views;
import eskimo.ComponentManager;
import eskimo.EntityManager;
import eskimo.bits.BitFlag;
import eskimo.ComponentManager.ComponentType;
import eskimo.containers.EntityArray;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class View
{
	
	private var _entities:EntityManager;
	
	public var filter:IFilter;
	
	public var entities:EntityArray;
	
	public var onAdd:Entity->Void;
	public var onUpdate:Entity->Void;
	public var onRemove:Entity->Void;
	
	public function new(filter:IFilter, ?_entities:EntityManager = null):Void
	{
		this.filter = filter;
		entities = new EntityArray();

		if (_entities != null) initialize(_entities);
	}
	
	public function initialize(_entities:EntityManager):Void
	{
		this._entities = _entities;
		
		filter.update(_entities.components);
		
		var includes = filter.getIncludes();
		for (index in 0...includes.length) _entities.components.getContainer(includes[index]).addView(this, index);
		
		for (e in _entities.entities) check(e);
	}
	
	public function update(e:Entity, index:Int):Void
	{
		check(e);
	}
	
	private function check(e:Entity):Void
	{
		if (filter.contains(e))
		{
			if (!entities.has(e))
			{
				entities.push(e);
				if (onAdd != null) onAdd(e);
			}
			else if (onUpdate != null) onUpdate(e);
		}
		else if (entities.has(e))
		{
			entities.remove(e);
			if (onRemove != null) onRemove(e);
		}
	}
	
	public function destroy():Void
	{
		for (include in filter.getIncludes()) _entities.components.getContainer(include).removeView(this);
	}
	
}
package eskimo.views;
import eskimo.Entity;
import eskimo.containers.EntityArray;
import eskimo.filters.IFilter;
import eskimo.views.View;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class EventView extends View
{
	
	public var added:EntityArray;
	public var updated:EntityArray;
	public var removed:EntityArray;
	
	public function new(filter:IFilter, ?_entities:EntityManager = null):Void
	{
		added = new EntityArray();
		updated = new EntityArray();
		removed = new EntityArray();
		
		super(filter, _entities);
	}
	
	public function clear():Void 
	{
		clearAdded();
		clearUpdated();
		clearRemoved();
	}
	
	public function clearAdded():Void
	{
		while (added.length > 0) added.pop();
	}
	
	public function clearUpdated():Void
	{
		while (updated.length > 0) updated.pop();
	}
	
	public function clearRemoved():Void
	{
		while (removed.length > 0) removed.pop();
	}
	
	override public function check(e:Entity):Void 
	{
		if (filter.contains(e))
		{
			if (removed.has(e)) removed.remove(e);
			
			if (entities.has(e))
			{
				if (!added.has(e) && !updated.has(e)) updated.push(e);
				
				if (onUpdate != null) onUpdate(e);
			}
			else
			{
				added.push(e);
				entities.push(e);
				
				if (onAdd != null) onAdd(e);
			}
		}
		else if (entities.has(e))
		{
			if (added.has(e)) added.remove(e);
			if (updated.has(e)) updated.remove(e);
			
			if (!removed.has(e)) removed.push(e);
			entities.remove(e);
			
			if (onRemove != null) onRemove(e);
		}
	}
	
}
package eskimo.events;
import eskimo.ComponentManager;
import eskimo.ComponentManager.IComponentType;
import eskimo.Entity;
import eskimo.containers.EntityArray;
import eskimo.events.IEntityDispatcher;
import eskimo.filters.BitFilter;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

class ViewEvents implements IEntityListener
{
	
	public var parent:IEntityDispatcher;
	
	public var filter:IFilter;
	
	public var added = new EntityArray();
	public var updated = new EntityArray();
	public var removed = new EntityArray();
	
	public function new(parent:IEntityDispatcher, filter:IFilter = null):Void
	{
		this.parent = parent;
		parent.listen(this);
		
		this.filter = filter;
		
		for (e in parent.source.entities) onAdd(e);
	}
	
	public function onAdd(e:Entity):Void
	{
		if (removed.has(e)) removed.remove(e);
		added.push(e);
	}
	
	public function onUpdate(e:Entity, type:IComponentType):Void
	{
		if (filter != null && filter.containsType(type) && !added.has(e)) updated.push(e);
	}
	
	public function onRemove(e:Entity):Void
	{
		added.remove(e);
		updated.remove(e);
		removed.push(e);
	}
	
	public function clear():Void 
	{
		clearAdded();
		clearUpdated();
		clearRemoved();
	}
	
	public function clearAdded():Void
	{
		added.clear();
	}
	
	public function clearUpdated():Void
	{
		updated.clear();
	}
	
	public function clearRemoved():Void
	{
		removed.clear();
	}
	
	public function dispose():Void
	{
		parent.unlisten(this);
	}
	
}
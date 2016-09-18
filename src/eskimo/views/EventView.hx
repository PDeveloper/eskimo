package eskimo.views;
import eskimo.ComponentManager.IComponentType;
import eskimo.Entity;
import eskimo.containers.EntityArray;
import eskimo.filters.Filter;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

class EventView implements IEntityListener
{
	
	public var filter:Filter;
	
	private var added_array = new EntityArray();
	public var  added(get, null):Array<Entity>;
	
	private var updated_array = new EntityArray();
	public var  updated(get, null):Array<Entity>;
	
	private var removed_array = new EntityArray();
	public var  removed(get, null):Array<Entity>;
	
	public function new(dispatcher:EntityDispatcher, filter:Filter = null):Void
	{
		dispatcher.listen(this);
		this.filter = filter;
	}
	
	public function onAdd(e:Entity):Void
	{
		removed_array.remove(e);
		added_array.push(e);
	}
	
	public function onUpdate(e:Entity, type:IComponentType):Void
	{
		if (filter != null && filter.includeFlag.contains(type.flag) && !added_array.has(e)) updated_array.push(e);
	}
	
	public function onRemove(e:Entity):Void
	{
		added_array.remove(e);
		updated_array.remove(e);
		removed_array.push(e);
	}
	
	function get_added():Array<Entity>
	{
		return added_array.entities;
	}
	
	function get_updated():Array<Entity>
	{
		return updated_array.entities;
	}
	
	function get_removed():Array<Entity>
	{
		return removed_array.entities;
	}
	
	public function clear():Void 
	{
		clearAdded();
		clearUpdated();
		clearRemoved();
	}
	
	public function clearAdded():Void
	{
		while (added_array.length > 0) added_array.pop();
	}
	
	public function clearUpdated():Void
	{
		while (updated_array.length > 0) updated_array.pop();
	}
	
	public function clearRemoved():Void
	{
		while (removed_array.length > 0) removed_array.pop();
	}
	
}
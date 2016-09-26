package eskimo.views;
import eskimo.ComponentManager.IComponentType;
import eskimo.EntityManager;
import eskimo.containers.EntityArray;
import eskimo.containers.IContainerListener;
import eskimo.filters.BitFilter;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

class ViewBase extends EntityDispatcher implements IContainerListener
{
	
	public var filter:IFilter;
	
	private var _entities:EntityManager;
	
	private var entities_array:EntityArray;
	public var entities:Array<Entity>;
	
	public inline function new(_entities:EntityManager = null, _filter:IFilter = null):Void
	{
		super();
		
		entities_array = new EntityArray();
		entities = entities_array.entities;
		
		this.filter = _filter != null ? _filter : new eskimo.filters.BitFilter([]);
		if (_entities != null) initialize(_entities);
	}
	
	public function initialize(_entities:EntityManager):Void
	{
		this._entities = _entities;
	}
	
	public function dispose():Void
	{
		
	}
	
	private function check(entity:Entity, type:IComponentType = null):Void
	{
		if (filter.contains(entity))
		{
			if (!entities_array.has(entity))
			{
				entities_array.push(entity);
				for (listener in listeners) listener.onAdd(entity);
			}
			else for (listener in listeners) listener.onUpdate(entity, type);
		}
		else if (entities_array.has(entity))
		{
			entities_array.remove(entity);
			for (listener in listeners) listener.onRemove(entity);
		}
	}
	
	public function update(e:Entity, type:IComponentType):Void 
	{
		check(e, type);
	}
	
}

@:genericBuild(eskimo.views.macros.ViewBuilder.build())
class View<Rest> {}
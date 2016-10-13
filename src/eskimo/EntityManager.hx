package eskimo;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

class EntityManager
{
	
	public var components:ComponentManager;
	
	private var entityId:Int;
	public var entities:Array<Entity>;
	
	public var onCreate:Entity->Void;
	public var onDestroy:Entity->Void;
	
	public function new(components:ComponentManager):Void
	{
		this.components = components;
		
		entityId = 1;
		entities = [];
	}
	
	public function create(components:Array<Dynamic> = null):Entity
	{
		var entity = new Entity(entityId++);
		entities.push(entity);
		
		this.components.create(entity);
		if (components != null) for (component in components) this.components.set(entity, component);
		
		if (onCreate != null) onCreate(entity);
		
		return entity;
	}
	
	public function destroy(entity:Entity):Void
	{
		if (onDestroy != null) onDestroy(entity);
		
		components.clear(entity);
		entities.remove(entity);
	}
	
	public function clear():Void
	{
		for (entity in entities)
		{
			if (onDestroy != null) onDestroy(entity);
			components.clear(entity);
		}
		entities = [];
	}
	
}
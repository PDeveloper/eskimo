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
		
		entityId = 0;
		entities = new Array<Entity>();
	}
	
	public function create(components:Array<Dynamic> = null):Entity
	{
		var e = new Entity(this, entityId++);
		entities.push(e);
		
		components = (components == null) ? [] : components;
		for (component in components) e.set(component);
		
		if (onCreate != null) onCreate(e);
		
		return e;
	}
	
	public function destroy(e:Entity):Void
	{
		if (onDestroy != null) onDestroy(e);
		
		components.clear(e);
		entities.remove(e);
	}
	
	public function clear():Void
	{
		while (entities.length > 0) destroy(entities[0]);
	}
	
}
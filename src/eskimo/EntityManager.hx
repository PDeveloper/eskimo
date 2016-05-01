package eskimo;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

class EntityManager
{
	
	public var context:Context;
	
	private var entityId:Int;
	public var entities:Array<Entity>;
	
	public var onCreate:Entity->Void;
	public var onDestroy:Entity->Void;
	
	public function new(context:Context):Void
	{
		this.context = context;
		
		entityId = 0;
		entities = new Array<Entity>();
	}
	
	public function create(components:Array<Dynamic> = null):Entity
	{
		var e = new Entity(context, entityId++);
		entities.push(e);
		
		components = (components == null) ? [] : components;
		for (component in components) e.set(component);
		
		if (onCreate != null) onCreate(e);
		
		return e;
	}
	
	public function destroy(e:Entity):Void
	{
		if (onDestroy != null) onDestroy(e);
		
		context.components.clear(e);
		entities.remove(e);
	}
	
	public function clear():Void
	{
		while (entities.length > 0) destroy(entities[0]);
	}
	
}
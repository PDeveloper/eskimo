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
	
	public function new(context:Context):Void
	{
		this.context = context;
		
		entityId = 0;
		entities = new Array<Entity>();
	}
	
	public function create():Entity
	{
		var e = new Entity(context, entityId++);
		entities.push(e);
		
		return e;
	}
	
	public function destroy(e:Entity):Void
	{
		context.components.clear(e);
		entities.remove(e);
	}
	
}
package eskimo;

/**
 * ...
 * @author PDeveloper
 */

class Context
{
	
	public var components:ComponentManager;
	public var entities:EntityManager;
	
	public function new():Void
	{
		components = new ComponentManager();
		entities = new EntityManager(this);
	}
	
	public function create():Entity
	{
		return entities.create();
	}
	
	public function destroy(e:Entity):Void
	{
		entities.destroy(e);
	}
	
}
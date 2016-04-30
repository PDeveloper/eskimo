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
	
}
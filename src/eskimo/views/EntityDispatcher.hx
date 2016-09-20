package eskimo.views;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.filters.BitFilter;
import eskimo.containers.EntityArray;
import eskimo.containers.IContainerListener;

/**
 * ...
 * @author PDeveloper
 */

class EntityDispatcher
{
	
	public var listeners = new Array<IEntityListener>();
	
	public function listen(listener:IEntityListener):Void
	{
		listeners.push(listener);
	}
	
	public function unlisten(listener:IEntityListener):Void
	{
		listeners.remove(listener);
	}
	
}
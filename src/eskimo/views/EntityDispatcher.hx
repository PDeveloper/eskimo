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

class EntityDispatcher implements IEntityDispatcher
{
	
	public var listeners:Array<IEntityListener>;
	
	public inline function new():Void
	{
		listeners = new Array<IEntityListener>();
	}
	
	public inline function listen(listener:IEntityListener):Void
	{
		listeners.push(listener);
	}
	
	public inline function unlisten(listener:IEntityListener):Void
	{
		listeners.remove(listener);
	}
	
}
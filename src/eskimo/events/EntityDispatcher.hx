package eskimo.events;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.core.IEntityBuffer;
import eskimo.filters.BitFilter;
import eskimo.containers.EntityArray;
import eskimo.containers.IContainerListener;

/**
 * ...
 * @author PDeveloper
 */

class EntityDispatcher implements IEntityDispatcher
{
	
	public var source:IEntityBuffer;
	public var listeners:Array<IEntityListener>;
	
	public inline function new(source:IEntityBuffer):Void
	{
		this.source = source;
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
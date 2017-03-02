package eskimo.events;
import eskimo.containers.EntityArray;
import eskimo.core.IEntityBuffer;
import eskimo.events.IEntityListener;

/**
 * @author PDeveloper
 */

interface IEntityDispatcher 
{
	
	public var source:IEntityBuffer;
	public function listen(listener:IEntityListener):Void;
	public function unlisten(listener:IEntityListener):Void;
	
}
package eskimo.filters;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

class CallbackFilter extends Filter
{
	
	private var callback:Entity->Bool;
	
	public function new(callback:Entity->Bool):Void
	{
		this.callback = callback;
	}
	
	override public function contains(entity:Entity):Bool 
	{
		return super.contains(entity) && callback(entity);
	}
	
}
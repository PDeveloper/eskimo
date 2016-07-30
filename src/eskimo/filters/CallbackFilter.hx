package eskimo.filters;
import eskimo.Entity;
import eskimo.EntityManager;

/**
 * ...
 * @author PDeveloper
 */

class CallbackFilter extends Filter
{
	
	private var callback:Entity->Bool;
	
	public function new(callback:Entity->Bool, includes:Array<Class<Dynamic>>, excludes:Array<Class<Dynamic>> = null, entities:EntityManager = null):Void
	{
		this.callback = callback;
		super(includes, excludes, entities);
	}
	
	override public function contains(entity:Entity):Bool 
	{
		return super.contains(entity) && callback(entity);
	}
	
}
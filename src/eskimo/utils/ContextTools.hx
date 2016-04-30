package eskimo.utils;
import eskimo.Context;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */
class ContextTools
{
	
	public static function create(context:Context):Entity
	{
		return context.entities.create();
	}
	
	public static function destroy(context:Context, e:Entity):Void
	{
		context.entities.destroy(e);
	}
	
	public static function clear(context:Context):Void
	{
		context.entities.clear();
	}
	
}
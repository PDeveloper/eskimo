package eskimo.utils;
import eskimo.Context;
import eskimo.Entity;
import eskimo.View;

/**
 * ...
 * @author PDeveloper
 */
class ContextTools
{
	
	public inline static function create(context:Context, components:Array<Dynamic> = null):Entity
	{
		components = (components == null) ? [] : components;
		return context.entities.create(components);
	}
	
	public inline static function destroy(context:Context, e:Entity):Void
	{
		context.entities.destroy(e);
	}
	
	public inline static function clear(context:Context):Void
	{
		context.entities.clear();
	}
	
	public inline static function view(context:Context, includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null):View
	{
		return new View(includes, excludes, context);
	}
	
}
package eskimo.filters;
import eskimo.Context;
import eskimo.Entity;
import eskimo.bits.BitFlag;

/**
 * ...
 * @author PDeveloper
 */

class Filter implements IFilter
{
	
	public var include_flag:BitFlag;
	public var includes:Array<Class<Dynamic>>;
	
	public var exclude_flag:BitFlag;
	public var excludes:Array<Class<Dynamic>>;
	
	public function new(includes:Array<Class<Dynamic>>, excludes:Array<Class<Dynamic>> = null, context:Context = null):Void
	{
		this.includes = includes;
		this.excludes = excludes == null ? [] : excludes;
		
		include_flag = new BitFlag();
		exclude_flag = new BitFlag();
		if (context != null) update(context);
	}
	
	public function include(componentClass:Class<Dynamic>):Void 
	{
		if (!includes.has(componentClass)) includes.push(componentClass);
	}
	
	public function dontInclude(componentClass:Class<Dynamic>):Void 
	{
		includes.remove(componentClass);
	}
	
	public function exclude(componentClass:Class<Dynamic>):Void 
	{
		if (!excludes.has(componentClass)) excludes.push(componentClass);
	}
	
	public function dontExclude(componentClass:Class<Dynamic>):Void 
	{
		excludes.remove(componentClass);
	}
	
	public function update(context:Context):Void
	{
		include_flag.clear();
		for (componentClass in includes) include_flag.setTrue(context.components.getType(componentClass).id + 1);
		
		exclude_flag.clear();
		for (componentClass in excludes) exclude_flag.setTrue(context.components.getType(componentClass).id + 1);
		exclude_flag.flip();
	}
	
	public inline function contains(entity:Entity):Bool
	{
		return entity.flag.contains(include_flag) && exclude_flag.contains(entity.flag);
	}
	
}
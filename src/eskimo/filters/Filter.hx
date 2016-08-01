package eskimo.filters;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.EntityManager;
import eskimo.bits.BitFlag;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class Filter implements IFilter
{
	
	private var include_flag:BitFlag;
	private var includes:Array<Class<Dynamic>>;
	
	private var exclude_flag:BitFlag;
	private var excludes:Array<Class<Dynamic>>;
	
	public function new(includes:Array<Class<Dynamic>>, excludes:Array<Class<Dynamic>> = null, components:ComponentManager = null):Void
	{
		this.includes = includes;
		this.excludes = excludes == null ? [] : excludes;
		
		include_flag = new BitFlag();
		exclude_flag = new BitFlag();
		if (components != null) update(components);
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
	
	public function update(components:ComponentManager):Void
	{
		include_flag.clear();
		for (componentClass in includes) include_flag.setTrue(components.getType(componentClass).id + 1);
		
		exclude_flag.clear();
		for (componentClass in excludes) exclude_flag.setTrue(components.getType(componentClass).id + 1);
		exclude_flag.flip();
	}
	
	public inline function contains(entity:Entity):Bool
	{
		return entity.flag.contains(include_flag) && exclude_flag.contains(entity.flag);
	}
	
	public function toString():String
	{
		function stringifyClass(_class:Class<Dynamic>):String
		{
			return Type.getClassName(_class);
		}
		
		return 'INC:[' + includes.map(stringifyClass).join(',') + '], EXC:[' + excludes.map(stringifyClass).join('::') + ']';
	}
	
	public function getIncludes():Array<Class<Dynamic>> 
	{
		return includes;
	}
	
	public function getExcludes():Array<Class<Dynamic>> 
	{
		return excludes;
	}
	
}
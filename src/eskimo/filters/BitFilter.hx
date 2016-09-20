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

class BitFilter implements IFilter
{
	
	public var includeFlag:BitFlag;
	private var includes:Array<Class<Dynamic>>;
	
	public var excludeFlag:BitFlag;
	private var excludes:Array<Class<Dynamic>>;
	
	public function new(includes:Array<Class<Dynamic>>, excludes:Array<Class<Dynamic>> = null, components:ComponentManager = null):Void
	{
		this.includes = includes;
		this.excludes = excludes == null ? [] : excludes;
		
		includeFlag = new BitFlag();
		excludeFlag = new BitFlag();
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
		includeFlag.clear();
		for (componentClass in includes) includeFlag.setTrue(components.getType(componentClass).id + 1);
		
		excludeFlag.clear();
		for (componentClass in excludes) excludeFlag.setTrue(components.getType(componentClass).id + 1);
		excludeFlag.flip();
	}
	
	public inline function contains(entity:Entity):Bool
	{
		return entity.flag.contains(includeFlag) && excludeFlag.contains(entity.flag);
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
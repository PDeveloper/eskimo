package eskimo.filters;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.EntityManager;

/**
 * ...
 * @author PDeveloper
 */

class NoFilter implements IFilter
{
	
	public function new():Void {}
	
	public function include(componentClass:Class<Dynamic>):Void {}
	public function dontInclude(componentClass:Class<Dynamic>):Void {}
	public function exclude(componentClass:Class<Dynamic>):Void {}
	public function dontExclude(componentClass:Class<Dynamic>):Void {}
	
	public function update(components:ComponentManager):Void {}
	
	public function contains(entity:Entity):Bool 
	{
		return true;
	}
	
	public function getIncludes():Array<Class<Dynamic>> 
	{
		return [];
	}
	
	public function getExcludes():Array<Class<Dynamic>> 
	{
		return [];
	}
	
	public function toString():String 
	{
		return 'INC ALL';
	}
	
}
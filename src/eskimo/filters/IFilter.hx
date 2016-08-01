package eskimo.filters;
import eskimo.Entity;
import eskimo.EntityManager;

/**
 * ...
 * @author PDeveloper
 */

interface IFilter
{
	
	public function include(componentClass:Class<Dynamic>):Void;
	public function dontInclude(componentClass:Class<Dynamic>):Void;
	public function exclude(componentClass:Class<Dynamic>):Void;
	public function dontExclude(componentClass:Class<Dynamic>):Void;
	
	public function update(components:ComponentManager):Void;
	public function contains(entity:Entity):Bool;
	
	public function getIncludes():Array<Class<Dynamic>>;
	public function getExcludes():Array<Class<Dynamic>>;
	
	public function toString():String;
	
}
package eskimo.filters;
import eskimo.Context;
import eskimo.Entity;

/**
 * @author PDeveloper
 */

interface IFilter
{
	
	public function include(componentClass:Class<Dynamic>):Void;
	public function dontInclude(componentClass:Class<Dynamic>):Void;
	public function exclude(componentClass:Class<Dynamic>):Void;
	public function dontExclude(componentClass:Class<Dynamic>):Void;
	
	public function update(context:Context):Void;
	public function contains(entity:Entity):Bool;
	
}
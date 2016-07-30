package;
import eskimo.Entity;

import Components;

/**
 * ...
 * @author PDeveloper
 */
class EntityHelper
{
	
	public static function addA(e:Entity, string:String):Entity
	{
		var c = new ComponentA(string);
		e.set(c);
		return e;
	}
	
	public static function addB(e:Entity, int:Int):Entity
	{
		var c = new ComponentB(int);
		e.set(c);
		return e;
	}
	
	public static function addC(e:Entity, d:Dynamic):Entity
	{
		var c = new ComponentC(d);
		e.set(c);
		return e;
	}
	
}
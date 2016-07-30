package;
import eskimo.systems.System;
import eskimo.systems.SystemManager;

/**
 * ...
 * @author ...
 */
class SystemA extends System
{
	
	public function new():Void
	{
		super();
	}
	
	override public function onActivate(systems:SystemManager):Void 
	{
		trace('SystemA is being added.');
	}
	
	override public function onUpdate(dt:Float):Void 
	{
		trace('SystemA is being updated.');
		work();
	}
	
	override public function onDeactivate(systems:SystemManager):Void 
	{
		trace('SystemA is being removed.');
	}
	
	public function work():Void
	{
		trace('SystemA is working.');
	}
	
}
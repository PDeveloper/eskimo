package;
import eskimo.systems.System;
import eskimo.systems.SystemManager;

/**
 * ...
 * @author ...
 */
class SystemB extends System
{
	
	public var systemA:SystemA;

	public function new():Void
	{
		super([SystemA]);
	}
	
	override public function onStart(systems:SystemManager):Void 
	{
		trace('SystemB is being added.');
		systemA = systems.get(SystemA);
		systemA.work();
	}
	
	override public function onUpdate(dt:Float):Void 
	{
		trace('SystemB is being updated.');
		systemA.work();
		work();
	}
	
	override public function onStop(systems:SystemManager):Void 
	{
		trace('SystemB is being removed.');
	}
	
	public function work():Void
	{
		trace('SystemB is working.');
	}
	
}
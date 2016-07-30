package;
import eskimo.systems.System;
import eskimo.systems.SystemManager;

/**
 * ...
 * @author ...
 */
class SystemC extends System
{
	
	public var systemA:SystemA;
	public var systemB:SystemB;
	
	public function new():Void
	{
		super([SystemA, SystemB]);
	}
	
	override public function onActivate(systems:SystemManager):Void 
	{
		trace('SystemC is being added.');
		systemA = systems.get(SystemA);
		systemB = systems.get(SystemB);
		
		systemA.work();
		systemB.work();
	}
	
	override public function onUpdate(dt:Float):Void 
	{
		trace('SystemC is being updated.');
		systemA.work();
		systemB.work();
		work();
	}
	
	override public function onDeactivate(systems:SystemManager):Void 
	{
		trace('SystemC is being removed.');
	}
	
	public function work():Void
	{
		trace('SystemC is working.');
	}
	
}
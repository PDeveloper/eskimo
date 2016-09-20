package eskimo.systems;
import eskimo.bits.BitFlag;

/**
 * ...
 * @author PDeveloper
 */

class System
{
	
	@:noCompletion
	@:allow(eskimo.systems.SystemManager)
	private var __active:Bool = false;
	
	@:noCompletion
	@:allow(eskimo.systems.SystemManager)
	private var __id:Int;
	
	@:noCompletion
	@:allow(eskimo.systems.SystemManager)
	private var __flag:BitFlag;
	
	@:noCompletion
	@:allow(eskimo.systems.SystemManager)
	private var __dependencies:Array<Class<System>>;
	
	public function new(dependencies:Array<Class<System>> = null):Void
	{
		__active = false;
		__id = -1;
		__flag = new BitFlag();
		__dependencies = dependencies != null? dependencies : [];
	}
	
	public function onInitialize(systems:SystemManager):Void
	{
		
	}
	
	public function onActivate(systems:SystemManager):Void
	{
		
	}
	
	public function onUpdate(dt:Float):Void
	{
		
	}
	
	public function onDeactivate(systems:SystemManager):Void
	{
		
	}
	
	public function onDispose(systems:SystemManager):Void
	{
		
	}
	
	public inline function isActive():Bool
	{
		return __active;
	}
	
}
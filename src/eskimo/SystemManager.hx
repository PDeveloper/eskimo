package eskimo;

/**
 * ...
 * @author PDeveloper
 */

class SystemManager
{
	
	public var context:Context;
	
	public var systems:Array<ISystem>;
	
	public function new(context:Context):Void
	{
		this.context = context;
		
		systems = new Array<ISystem>();
	}
	
	public function add(system:ISystem):Void
	{
		system.onAdd(context);
		systems.push(system);
	}
	
	public function remove(system:ISystem):Void
	{
		systems.remove(system);
		system.onRemove(context);
	}
	
	public function update(dt:Float):Void
	{
		for (system in systems) system.update(dt);
	}
	
}
package eskimo.systems;
import eskimo.EntityManager;
import eskimo.bits.BitFlag;

/**
 * ...
 * @author ...
 */

class SystemManager
{
	
	public var entities:EntityManager;
	
	private var systemIds:Map<String, Int>;
	private var systems:Map<String, System>;
	
	private var currentSystemId:Int;
	private var systemFlag:BitFlag;
	
	public function new(entities:EntityManager) 
	{
		this.entities = entities;
		
		systemIds = new Map<String, Int>();
		systems = new Map<String, System>();
		
		currentSystemId = 0;
		systemFlag = new BitFlag();
	}
	
	public function update(dt:Float):Void
	{
		for (system in systems) if (system.isActive()) system.onUpdate(dt);
	}
	
	public function add(system:System):Void
	{
		var systemClass = Type.getClass(system);
		var systemClassName = Type.getClassName(systemClass);
		
		systems.set(systemClassName, system);
		
		system.__id = getSystemId(systemClassName);
		systemFlag.setTrue(system.__id + 1);
		
		initializeDependencies(system);
		evaluateSystems();
	}
	
	public function remove(system:System):Void
	{
		var systemClassName = getClassName(system);
		
		if (systems.remove(systemClassName))
		{
			if (system.isActive()) system.onStop(this);
			
			systemFlag.setFalse(system.__id + 1);
			evaluateSystems();
		}
	}
	
	public function has<T:System>(systemClass:Class<System>):Bool
	{
		return systems.exists(Type.getClassName(systemClass));
	}
	
	public function get<T:System>(systemClass:Class<System>):T
	{
		return cast systems.get(Type.getClassName(systemClass));
	}
	
	private inline function initializeDependencies(system:System):Void
	{
		system.__flag.clear();
		
		for (dependency in system.__dependencies)
		{
			var id = getSystemId(Type.getClassName(dependency));
			system.__flag.setTrue(id + 1);
		}
	}
	
	private inline function evaluateSystems():Void
	{
		var isValid = false;
		
		while (!isValid)
		{
			isValid = true;
			for (system in systems) if (!evaluateDependencies(system)) isValid = false;
		}
	}
	
	private inline function evaluateDependencies(system:System):Bool
	{
		var isValid = true;
		if (systemFlag.contains(system.__flag))
		{
			if (!system.__active)
			{
				var is_active = true;
				
				for (dependency in system.__dependencies)
				{
					var required_system = systems.get(Type.getClassName(dependency));
					if (!required_system.__active) is_active = false;
				}
				
				system.__active = is_active;
				system.onStart(this);
				
				isValid = false;
			}
		}
		else if (system.__active)
		{
			system.__active = false;
			system.onStop(this);
			
			isValid = false;
		}
		
		return isValid;
	}
	
	private inline function getSystemId(systemClassName:String):Int
	{
		if (systemIds.exists(systemClassName)) return systemIds.get(systemClassName);
		else
		{
			var id = currentSystemId++;
			systemIds.set(systemClassName, id);
			return id;
		}
	}
	
	private inline function getClassName(obj:Dynamic):String
	{
		return Type.getClassName(Type.getClass(obj));
	}
	
}
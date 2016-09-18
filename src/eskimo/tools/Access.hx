package eskimo.tools;
import eskimo.ComponentManager;
import eskimo.ComponentManager.ComponentType;
import eskimo.EntityManager;
import eskimo.containers.Container;

/**
 * ...
 * @author PDeveloper
 */

@:generic class Access<T>
{
	
	public var componentClass:Class<T>;
	public var container:Container<T>;
	
	public function new(componentClass:Class<T>, ?components:ComponentManager = null):Void
	{
		this.componentClass = componentClass;
		
		if (components != null) initialize(components);
	}
	
	public function initialize(components:ComponentManager):Void
	{
		this.container = components.getContainer(componentClass);
	}
	
	public inline function set(e:Entity, component:T):Void
	{
		container.set(e, component);
	}
	
	public inline function get(e:Entity):T
	{
		return container.get(e);
	}
	
	public inline function has(e:Entity):Bool
	{
		return container.has(e);
	}
	
	public inline function remove(e:Entity):Void
	{
		container.remove(e);
	}
	
}
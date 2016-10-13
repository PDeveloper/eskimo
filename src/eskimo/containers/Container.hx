package eskimo.containers;
import eskimo.ComponentManager;
import eskimo.ComponentManager.ComponentType;
import eskimo.containers.Container.IContainer;

/**
 * ...
 * @author PDeveloper
 */

interface IContainer
{
	
	public function getUnsafe(e:Entity):Dynamic;
	public function has(e:Entity):Bool;
	public function remove(e:Entity):Void;
	
}

class Container<T> implements IContainer
{
	
	public var type:ComponentType<T>;
	public var components:ComponentManager;
	
	public var storage:Array<T>; // temporary to allow fast access - inlining doesn't work well on hxcpp
	private var listeners:Array<IContainerListener>;
	
	public inline function new(type:ComponentType<T>, components:ComponentManager):Void
	{
		this.type = type;
		this.components = components;
		
		storage = new Array<T>();
		listeners = new Array<IContainerListener>();
	}
	
	private inline function _set(entity:Entity, component:T):Void
	{
		if (component != null) components.flag(entity).add(type.flag);
		else components.flag(entity).sub(type.flag);
		
		storage[entity.id()] = component;
		
		components.onContainerComponentSet(entity, type, component);
		for (listener in listeners) listener.update(entity, type);
	}
	
	public inline function set(entity:Entity, component:T):Void
	{
		_set(entity, component);
	}
	
	public inline function get(entity:Entity):T
	{
		return storage[entity.id()];
	}
	
	public inline function getUnsafe(entity:Entity):Dynamic
	{
		return storage[entity.id()];
	}
	
	public function has(entity:Entity):Bool
	{
		return storage[entity.id()] != null;
	}
	
	public function remove(entity:Entity):Void
	{
		_set(entity, null);
	}
	
	public inline function listen(listener:IContainerListener):Void
	{
		listeners.push(listener);
	}
	
	public inline function unlisten(listener:IContainerListener):Void
	{
		listeners.remove(listener);
	}
	
}
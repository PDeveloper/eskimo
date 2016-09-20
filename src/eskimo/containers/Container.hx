package eskimo.containers;
import eskimo.ComponentManager;
import eskimo.ComponentManager.ComponentType;
import eskimo.containers.Container.IContainerBase;

/**
 * ...
 * @author PDeveloper
 */

interface IContainerBase
{
	
	public function getUnsafe(e:Entity):Dynamic;
	public function has(e:Entity):Bool;
	public function remove(e:Entity):Void;
	
}

interface IContainer<T> extends IContainerBase
{
	
	public function set(e:Entity, component:T):Void;
	public function get(e:Entity):T;
	
}

class Container<T> implements IContainer<T>
{
	
	public var type:ComponentType<T>;
	public var manager:ComponentManager;
	
	private var storage:Array<T>;
	private var listeners:Array<IContainerListener>;
	
	public var onComponentSet:Entity->T->Void;
	
	public function new(type:ComponentType<T>, manager:ComponentManager):Void
	{
		this.type = type;
		this.manager = manager;
		
		storage = new Array<T>();
		listeners = new Array<IContainerListener>();
	}
	
	private inline function _set(e:Entity, component:T):Void
	{
		if (component != null) e.flag.add(type.flag);
		else e.flag.sub(type.flag);
		
		storage[e.id] = component;
		
		// trigger callbacks
		if (onComponentSet != null) onComponentSet(e, component);
		manager._onComponentSet(e, type, component);
		
		for (listener in listeners) listener.update(e, type);
	}
	
	public function set(e:Entity, component:T):Void
	{
		_set(e, component);
	}
	
	public function get(e:Entity):T
	{
		return storage[e.id];
	}
	
	public function getId(id:Int):T
	{
		return storage[id];
	}
	
	public function getUnsafe(e:Entity):Dynamic
	{
		return storage[e.id];
	}
	
	public function has(e:Entity):Bool
	{
		return storage[e.id] != null;
	}
	
	public function remove(e:Entity):Void
	{
		_set(e, null);
	}
	
	public function listen(listener:IContainerListener):Void
	{
		listeners.push(listener);
	}
	
	public function unlisten(listener:IContainerListener):Void
	{
		listeners.remove(listener);
	}
	
}
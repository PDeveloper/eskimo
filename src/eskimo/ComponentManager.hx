package eskimo;
import eskimo.bits.BitFlag;
import eskimo.Container.IContainer;

/**
 * ...
 * @author PDeveloper
 */

interface IComponentType
{
	public var id:Int;
	public var flag:BitFlag;
}

class ComponentType<T> implements IComponentType
{
	
	public var id:Int;
	public var flag:BitFlag;
	
	public var className:String;
	public var componentClass:Class<T>;
	
	public function new(id:Int, componentClass:Class<T>):Void
	{
		this.id = id;
		this.componentClass = componentClass;
		
		flag = new BitFlag();
		flag.set(id + 1, 1);
		
		className = Type.getClassName(componentClass);
	}
	
}

class ComponentManager
{
	
	private var types:Map<String, IComponentType>;
	private var containers:Array<IContainer>;
	
	public var onComponentSet:Entity->Dynamic->Void;
	
	public function new():Void
	{
		types = new Map<String, IComponentType>();
		containers = new Array<IContainer>();
	}
	
	@:allow(eskimo.Container)
	private function _onComponentSet<T>(e:Entity, type:ComponentType<T>, component:T):Void
	{
		if (onComponentSet != null) onComponentSet(e, component);
	}
	
	public function set<T>(e:Entity, component:T):Void
	{
		var container:Container<T> = getContainer(Type.getClass(component));
		container.set(e, component);
	}
	
	public function get<T>(e:Entity, componentClass:Class<T>):T
	{
		var container:Container<T> = getContainer(componentClass);
		return container.get(e);
	}
	
	public function getByType<T>(e:Entity, type:ComponentType<T>):T
	{
		var container:Container<T> = getContainerByType(type);
		return container.get(e);
	}
	
	public function remove<T>(e:Entity, componentClass:Class<T>):Void
	{
		var container:Container<T> = getContainer(componentClass);
		container.remove(e);
	}
	
	public function has<T>(e:Entity, componentClass:Class<T>):Bool
	{
		return get(e, componentClass) != null;
	}
	
	public function clear(e:Entity):Void
	{
		for (container in containers) container.remove(e);
	}
	
	public inline function getContainer<T>(componentClass:Class<T>):Container<T>
	{
		var type = getType(componentClass);
		return getContainerByType(type);
	}
	
	public inline function getContainerByType<T>(type:IComponentType):Container<T>
	{
		return cast containers[type.id];
	}
	
	public function getEntityComponents(e:Entity):Array<Dynamic>
	{
		var components = new Array<Dynamic>();
		for (container in containers)
		{
			if (container.has(e)) components.push(container.getUnsafe(e));
		}
		
		return components;
	}
	
	public function getType<T>(componentClass:Class<T>):IComponentType
	{
		var className = Type.getClassName(componentClass);
		
		if (types.exists(className)) return types.get(className);
		else
		{
			var type_id = containers.length;
			var type = new ComponentType<T>(type_id, componentClass);
			containers[type_id] = new Container<T>(type, this);
			
			types.set(className, type);
			return type;
		}
	}
	
}
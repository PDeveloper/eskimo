package eskimo;
import eskimo.containers.Container;
import eskimo.bits.BitFlag;
import eskimo.containers.Container.IContainerBase;

/**
 * ...
 * @author PDeveloper
 */

interface IComponentType
{
	public var id:Int;
	public var flag:BitFlag;
	
	public function getClass():Class<Dynamic>;
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
	
	public function getClass():Class<Dynamic>
	{
		return componentClass;
	}
	
}

class ComponentManager
{
	
	private var types:Map<String, IComponentType>;
	private var containers:Array<IContainerBase>;
	
	private var flags:Array<BitFlag>;
	
	public var onComponentSet:Entity->Dynamic->Void;
	
	public function new():Void
	{
		types = new Map<String, IComponentType>();
		containers = new Array<IContainerBase>();
		
		flags = new Array<BitFlag>();
	}
	
	@:allow(eskimo.containers.IContainerBase)
	private function _onComponentSet<T>(e:Entity, type:ComponentType<T>, component:T):Void
	{
		if (onComponentSet != null) onComponentSet(e, component);
	}
	
	public inline function create(entity:Entity):Void
	{
		flags[entity] = new BitFlag();
	}
	
	public inline function flag(entity:Entity):BitFlag
	{
		return flags[entity];
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
	
	public function getComponentClasses():Array<Class<Dynamic>>
	{
		var classes = [];
		for (type in types) classes.push(type.getClass());
		return classes;
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
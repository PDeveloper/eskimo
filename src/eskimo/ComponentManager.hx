package eskimo;
import eskimo.containers.Container;
import eskimo.bits.BitFlag;
import eskimo.containers.Container.IContainer;

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
	private var containers:Array<IContainer>;
	
	private var flags:Array<BitFlag>;
	
	public var onComponentSet:Entity->IComponentType->Dynamic->Void;
	
	public function new():Void
	{
		types = new Map<String, IComponentType>();
		containers = new Array<IContainer>();
		
		flags = new Array<BitFlag>();
	}
	
	@:allow(eskimo.containers.IContainer)
	private function onContainerComponentSet<T>(entity:Entity, type:ComponentType<T>, component:T):Void
	{
		if (onComponentSet != null) onComponentSet(entity, type, component);
	}
	
	public inline function create(entity:Entity):Void
	{
		flags[entity.id()] = new BitFlag();
	}
	
	public inline function flag(entity:Entity):BitFlag
	{
		return flags[entity.id()];
	}
	
	public function set<T>(entity:Entity, component:T):Void
	{
		var container:Container<T> = getContainer(Type.getClass(component));
		container.set(entity, component);
	}
	
	public function get<T>(entity:Entity, componentClass:Class<T>):T
	{
		var container:Container<T> = getContainer(componentClass);
		return container.get(entity);
	}
	
	public function getByType<T>(entity:Entity, type:ComponentType<T>):T
	{
		var container:Container<T> = getContainerByType(type);
		return container.get(entity);
	}
	
	public function remove<T>(entity:Entity, componentClass:Class<T>):Void
	{
		var container:Container<T> = getContainer(componentClass);
		container.remove(entity);
	}
	
	public function has<T>(entity:Entity, componentClass:Class<T>):Bool
	{
		return get(entity, componentClass) != null;
	}
	
	public function clear(entity:Entity):Void
	{
		for (container in containers) container.remove(entity);
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
	
	public function getEntityComponents(entity:Entity):Array<Dynamic>
	{
		var components = new Array<Dynamic>();
		for (container in containers)
		{
			if (container.has(entity)) components.push(container.getUnsafe(entity));
		}
		
		return components;
	}
	
	public function getTypes():Array<IComponentType>
	{
		var _types = [];
		for (type in types) _types.push(type);
		return _types;
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
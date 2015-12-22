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
	
	private var typeId:Int;
	private var types:Map<String, IComponentType>;
	
	public var context:Context;
	
	private var containers:Array<IContainer>;
	
	public var onSetComponent:Entity->Dynamic->Void;
	
	public function new(context:Context):Void
	{
		this.context = context;
		
		typeId = 0;
		types = new Map<String, IComponentType>();
		
		containers = new Array<IContainer>();
	}
	
	public function set<T>(e:Entity, component:T):Void
	{
		var type = getType(Type.getClass(component));
		var container:Container<T> = cast containers[type.id];
		container.set(e, component);
		
		if (onSetComponent != null) onSetComponent(e, component);
	}
	
	public function get<T>(e:Entity, componentClass:Class<T>):T
	{
		var type = getType(componentClass);
		var container:Container<T> = cast containers[type.id];
		return container.get(e);
	}
	
	public function getByType<T>(e:Entity, type:ComponentType<T>):T
	{
		var container:Container<T> = cast containers[type.id];
		return container.get(e);
	}
	
	public function remove<T>(e:Entity, componentClass:Class<T>):Void
	{
		var type = getType(componentClass);
		var container:Container<T> = cast containers[type.id];
		container.remove(e);
		
		if (onSetComponent != null) onSetComponent(e, null);
	}
	
	public function has<T>(e:Entity, componentClass:Class<T>):Bool
	{
		return get(e, componentClass) != null;
	}
	
	public function clear(e:Entity):Void
	{
		for (container in containers) container.remove(e);
	}
	
	public function getContainer<T>(componentClass:Class<T>):Container<T>
	{
		var type = getType(componentClass);
		return cast containers[type.id];
	}
	
	public function getContainerByType<T>(type:IComponentType):Container<T>
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
			var type = new ComponentType<T>(typeId, componentClass);
			containers[typeId] = new Container<T>(type, this);
			
			typeId++;
			
			types.set(className, type);
			return type;
		}
	}
	
}
package eskimo;
import cpp.vm.Mutex;
import eskimo.ComponentManager.ComponentType;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

using eskimo.utils.ContextTools;

class ThreadContext extends Context
{
	
	private var contexts:Array<ThreadContext>;
	
	private var entity_map:Map<Int, Entity>;
	
	private var update_entities:Array<Entity>;
	private var update_components:Array<Dynamic>;
	
	private var update_mutex:Mutex;
	private var map_mutex:Mutex;
	
	private var isUpdating:Bool;
	
	public function new():Void
	{
		super();
		
		components.onComponentSet = onComponentSet;
		
		contexts = new Array<ThreadContext>();
		
		entity_map = new Map<Int, Entity>();
		
		update_entities = new Array<Entity>();
		update_components = new Array<Dynamic>();
		
		update_mutex = new Mutex();
		map_mutex = new Mutex();
		
		isUpdating = false;
	}
	
	public function update():Void
	{
		update_mutex.acquire();
		
		isUpdating = true;
		
		update_entities.reverse();
		update_components.reverse();
		
		while (update_entities.length > 0)
		{
			var e = update_entities.pop();
			var c = update_components.pop();
			
			e.set(c);
		}
		
		isUpdating = false;
		
		update_mutex.release();
	}
	
	public function onComponentSet<T>(e:Entity, type:ComponentType<T>):Void 
	{
		if (isUpdating) return;
		
		for (context in contexts)
		{
			var component = components.getByType(e, type);
			var foreign_id = context.onForeignComponentSet(e, component);
			
			map_mutex.acquire();
			entity_map.set(foreign_id, e);
			map_mutex.release();
		}
	}
	
	private function onForeignComponentSet<T>(foreign_e:Entity, component:T):Int
	{
		var e:Entity = null;
		
		map_mutex.acquire();
		if (!entity_map.exists(foreign_e.id))
		{
			e = create();
			entity_map.set(foreign_e.id, e);
		}
		else e = entity_map.get(foreign_e.id);
		map_mutex.release();
		
		update_mutex.acquire();
		
		update_entities.push(e);
		update_components.push(component);
		
		update_mutex.release();
		
		return e.id;
	}
	
	public function add(context:ThreadContext):Void
	{
		contexts.push(context);
		context.contexts.push(this);
	}
	
	public function remove(context:ThreadContext):Void
	{
		contexts.remove(context);
		context.contexts.remove(this);
	}
	
}
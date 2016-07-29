package eskimo.containers;
import eskimo.ComponentManager;
import eskimo.ComponentManager.ComponentType;
import eskimo.views.View;

/**
 * ...
 * @author PDeveloper
 */

class ViewListener
{
	
	public var view:View;
	public var index:Int;
	
	public function new (view:View, index:Int):Void
	{
		this.view = view;
		this.index = index;
	}
	
}

interface IContainer
{
	
	public function getUnsafe(e:Entity):Dynamic;
	public function has(e:Entity):Bool;
	public function remove(e:Entity):Void;
	
}

@:generic
class Container<T> implements IContainer
{
	
	public var type:ComponentType<T>;
	public var manager:ComponentManager;
	
	private var storage:Array<T>;
	private var views:Array<ViewListener>;
	
	public var onComponentSet:Entity->T->Void;
	
	public function new(type:ComponentType<T>, manager:ComponentManager):Void
	{
		this.type = type;
		this.manager = manager;
		
		storage = new Array<T>();
		views = new Array<ViewListener>();
	}
	
	private function _set(e:Entity, component:T):Void
	{
		if (component != null) e.flag.add(type.flag);
		else e.flag.sub(type.flag);
		
		storage[e.id] = component;
		
		// trigger callbacks
		if (onComponentSet != null) onComponentSet(e, component);
		manager._onComponentSet(e, type, component);
		
		for (view in views) view.view.update(e, view.index);
	}
	
	public function set(e:Entity, component:T):Void
	{
		_set(e, component);
	}
	
	public function get(e:Entity):T
	{
		return storage[e.id];
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
	
	// View API
	public function addView(view:View, index:Int = 0):Void
	{
		views.push(new ViewListener(view, index));
	}
	
	public function removeView(view:View):Void
	{
		views = views.filter(function (listener:ViewListener):Bool
		{
			if (listener.view == view) return false;
			return true;
		});
	}
	
}
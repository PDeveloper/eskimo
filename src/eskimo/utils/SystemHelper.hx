package eskimo.utils;
import eskimo.Context;
import eskimo.Entity;
import eskimo.EventView;

/**
 * ...
 * @author PDeveloper
 */

class SystemHelper
{
	
	private var _views:Map<String, EventView>;
	
	public var context:Context;
	
	public function new(context:Context):Void
	{
		this.context = context;
		_views = new Map<String, EventView>();
	}
	
	private function stringifyClass(_class:Class<Dynamic>):String
	{
		return Type.getClassName(_class);
	}
	
	private inline function getViewFor(includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null):EventView
	{
		var string_id = includes.map(stringifyClass).join('::') + '||' + (excludes != null ? excludes.map(stringifyClass).join('::') : '');
		
		if (_views.exists(string_id)) return _views.get(string_id);
		
		var view = new EventView(includes, excludes, context);
		_views.set(string_id, view);
		
		return view;
	}
	
	public function entities(onEntity:Entity->Void, includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null):Void
	{
		var view = getViewFor(includes, excludes);
		for (e in view.entities) onEntity(e);
	}
	
	public function added(onEntity:Entity->Void, includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, clear:Bool = true):Void
	{
		var view = getViewFor(includes, excludes);
		for (e in view.added) onEntity(e);
		if (clear) view.clearAdded();
	}
	
	public function updated(onEntity:Entity->Void, includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, clear:Bool = true):Void
	{
		var view = getViewFor(includes, excludes);
		for (e in view.updated) onEntity(e);
		if (clear) view.clearUpdated();
	}
	
	public function removed(onEntity:Entity->Void, includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, clear:Bool = true):Void
	{
		var view = getViewFor(includes, excludes);
		for (e in view.removed) onEntity(e);
		if (clear) view.clearRemoved();
	}
	
}
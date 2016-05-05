package eskimo.utils;
import eskimo.Context;
import eskimo.Entity;
import eskimo.EventView;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

class SystemCreator
{
	
	private var _views:Map<String, EventView>;
	
	public var context:Context;
	
	public function new(context:Context):Void
	{
		this.context = context;
		_views = new Map<String, EventView>();
	}
	
	private inline function getViewFor(filter:IFilter):EventView
	{
		var string_id = filter.toString();
		if (_views.exists(string_id)) return _views.get(string_id);
		
		filter.update(context);
		
		var view = new EventView(filter.getIncludes(), filter.getExcludes(), context);
		_views.set(string_id, view);
		
		return view;
	}
	
	public function entities(onEntity:Entity->Void, filter:IFilter):Void
	{
		var view = getViewFor(filter);
		for (e in view.entities) onEntity(e);
	}
	
	public function added(onEntity:Entity->Void, filter:IFilter, clear:Bool = true):Void
	{
		var view = getViewFor(filter);
		for (e in view.added) onEntity(e);
		if (clear) view.clearAdded();
	}
	
	public function updated(onEntity:Entity->Void, filter:IFilter, clear:Bool = true):Void
	{
		var view = getViewFor(filter);
		for (e in view.updated) onEntity(e);
		if (clear) view.clearUpdated();
	}
	
	public function removed(onEntity:Entity->Void, filter:IFilter, clear:Bool = true):Void
	{
		var view = getViewFor(filter);
		for (e in view.removed) onEntity(e);
		if (clear) view.clearRemoved();
	}
	
}
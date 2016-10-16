package eskimo.tools;
import eskimo.Entity;
import eskimo.EntityManager;
import eskimo.events.ViewEvents;
import eskimo.filters.IFilter;

/**
 * ...
 * @author PDeveloper
 */

class SystemCreator
{
	
	private var _views:Map<String, ViewEvents>;
	
	public var entities:EntityManager;
	
	public function new(entities:EntityManager):Void
	{
		this.entities = entities;
		_views = new Map<String, ViewEvents>();
	}
	
	private inline function getViewFor(filter:IFilter):ViewEvents
	{
		var string_id = filter.toString();
		if (_views.exists(string_id)) return _views.get(string_id);
		
		filter.update(context);
		
		var view = new ViewEvents(filter.getIncludes(), filter.getExcludes(), entities);
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
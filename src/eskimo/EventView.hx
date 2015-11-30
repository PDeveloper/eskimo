package eskimo;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class EventView extends View
{
	
	public var added:Array<Entity>;
	public var updated:Array<Entity>;
	public var removed:Array<Entity>;
	
	public function new(includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, ?context:Context = null):Void
	{
		added = new Array<Entity>();
		updated = new Array<Entity>();
		removed = new Array<Entity>();
		
		super(includes, excludes, context);
	}
	
	public function clear():Void 
	{
		while (added.length > 0) added.pop();
		while (updated.length > 0) updated.pop();
		while (removed.length > 0) removed.pop();
	}
	
	override public function check(e:Entity):Void 
	{
		if (e.flag.contains(includeFlag) && excludeFlag.contains(e.flag))
		{
			if (removed.has(e)) removed.remove(e);
			
			if (entities.has(e))
			{
				if (!added.has(e) && !updated.has(e)) updated.push(e);
				
				if (onUpdate != null) onUpdate(e);
			}
			else
			{
				added.push(e);
				entities.push(e);
				
				if (onAdd != null) onAdd(e);
			}
		}
		else if (entities.has(e))
		{
			if (added.has(e)) added.remove(e);
			if (updated.has(e)) updated.remove(e);
			
			if (!removed.has(e)) removed.push(e);
			entities.remove(e);
			
			if (onRemove != null) onRemove(e);
		}
	}
	
}
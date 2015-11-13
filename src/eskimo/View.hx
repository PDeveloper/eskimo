package eskimo;
import eskimo.ComponentManager;
import eskimo.bits.BitFlag;
import eskimo.ComponentManager.ComponentType;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class View
{
	
	private var context:Context;
	
	private var includeFlag:BitFlag;
	private var includes:Array<Class<Dynamic>>;
	private var excludeFlag:BitFlag;
	private var excludes:Array<Class<Dynamic>>;
	
	public var added:Array<Entity>;
	public var updated:Array<Entity>;
	public var removed:Array<Entity>;
	
	public var entities:Array<Entity>;
	
	private var isActive:Bool;
	
	public function new(includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, ?context:Context = null):Void
	{
		this.includes = includes;
		this.excludes = (excludes != null) ? excludes : new Array<Class<Dynamic>>();
		
		added = new Array<Entity>();
		updated = new Array<Entity>();
		removed = new Array<Entity>();
		
		entities = new Array<Entity>();
		
		isActive = false;
		
		if (context != null) initialize(context);
	}
	
	public function initialize(context:Context):Void
	{
		this.context = context;
		
		includeFlag = new BitFlag();
		for (index in 0...includes.length)
		{
			var include = includes[index];
			
			includeFlag.set(context.components.getType(include).id + 1, 1);
			context.components.getContainer(include).addView(this, index);
		}
		
		excludeFlag = new BitFlag();
		if (excludes != null)
			for (exclude in excludes) excludeFlag.set(context.components.getType(exclude).id + 1, 1);
		excludeFlag.flip();
		
		for (e in context.entities.entities) check(e);
	}
	
	public function begin():Void
	{
		isActive = true;
	}
	
	public function end():Void
	{
		isActive = false;
		
		while (added.length > 0) added.pop();
		while (updated.length > 0) updated.pop();
		while (removed.length > 0) removed.pop();
	}
	
	public function update(e:Entity, index:Int):Void
	{
		if (isActive) return;
		check(e);
	}
	
	public function check(e:Entity):Void
	{
		if (e.flag.contains(includeFlag) && excludeFlag.contains(e.flag))
		{
			if (removed.has(e)) removed.remove(e);
			
			if (entities.has(e))
			{
				if (!added.has(e) && !updated.has(e)) updated.push(e);
			}
			else
			{
				added.push(e);
				entities.push(e);
			}
		}
		else if (entities.has(e))
		{
			if (added.has(e)) added.remove(e);
			if (updated.has(e)) updated.remove(e);
			
			if (!removed.has(e)) removed.push(e);
			entities.remove(e);
		}
	}
	
	public function destroy():Void
	{
		for (include in includes) context.components.getContainer(include).removeView(this);
	}
	
}
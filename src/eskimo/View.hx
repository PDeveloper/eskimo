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
	
	public var entities:Array<Entity>;
	
	public function new(includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, ?context:Context = null):Void
	{
		this.includes = includes;
		this.excludes = (excludes != null) ? excludes : new Array<Class<Dynamic>>();
		
		entities = new Array<Entity>();
		
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
	
	public function update(e:Entity, index:Int):Void
	{
		check(e);
	}
	
	private function check(e:Entity):Void
	{
		if (e.flag.contains(includeFlag) && excludeFlag.contains(e.flag))
		{
			if (!entities.has(e)) entities.push(e);
		}
		else if (entities.has(e)) entities.remove(e);
	}
	
	public function destroy():Void
	{
		for (include in includes) context.components.getContainer(include).removeView(this);
	}
	
}
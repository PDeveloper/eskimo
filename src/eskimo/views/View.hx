package eskimo.views;
import eskimo.ComponentManager;
import eskimo.EntityManager;
import eskimo.bits.BitFlag;
import eskimo.ComponentManager.ComponentType;
import eskimo.containers.EntityArray;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class View
{
	
	private var _entities:EntityManager;
	
	private var includeFlag:BitFlag;
	private var includes:Array<Class<Dynamic>>;
	private var excludeFlag:BitFlag;
	private var excludes:Array<Class<Dynamic>>;
	
	public var entities:EntityArray;
	
	public var onAdd:Entity->Void;
	public var onUpdate:Entity->Void;
	public var onRemove:Entity->Void;
	
	public function new(includes:Array<Class<Dynamic>>, ?excludes:Array<Class<Dynamic>> = null, ?_entities:EntityManager = null):Void
	{
		this.includes = includes;
		this.excludes = (excludes != null) ? excludes : new Array<Class<Dynamic>>();
		
		entities = new EntityArray();
		
		if (_entities != null) initialize(_entities);
	}
	
	public function initialize(_entities:EntityManager):Void
	{
		this._entities = _entities;
		
		includeFlag = new BitFlag();
		for (index in 0...includes.length)
		{
			var include = includes[index];
			
			includeFlag.set(_entities.components.getType(include).id + 1, 1);
			_entities.components.getContainer(include).addView(this, index);
		}
		
		excludeFlag = new BitFlag();
		if (excludes != null)
			for (exclude in excludes) excludeFlag.set(_entities.components.getType(exclude).id + 1, 1);
		excludeFlag.flip();
		
		for (e in _entities.entities) check(e);
	}
	
	public function update(e:Entity, index:Int):Void
	{
		check(e);
	}
	
	private function check(e:Entity):Void
	{
		if (e.flag.contains(includeFlag) && excludeFlag.contains(e.flag))
		{
			if (!entities.has(e))
			{
				entities.push(e);
				if (onAdd != null) onAdd(e);
			}
			else if (onUpdate != null) onUpdate(e);
		}
		else if (entities.has(e))
		{
			entities.remove(e);
			if (onRemove != null) onRemove(e);
		}
	}
	
	public function destroy():Void
	{
		for (include in includes) _entities.components.getContainer(include).removeView(this);
	}
	
}
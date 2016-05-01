package eskimo;
import cpp.Void;
import eskimo.bits.BitFlag;
import eskimo.Context;
import haxe.Serializer;
import haxe.Unserializer;

/**
 * ...
 * @author PDeveloper
 */

class Entity
{
	
	private var context:Context;
	public var id:Int;
	
	public var flag:BitFlag;
	
	public function new(context:Context, id:Int):Void
	{
		this.context = context;
		this.id = id;
		
		this.flag = new BitFlag();
	}
	
	public function set<T>(component:T):Void
	{
		context.components.set(this, component);
	}
	
	public function get<T>(componentClass:Class<T>):T
	{
		return context.components.get(this, componentClass);
	}
	
	public function remove<T>(componentClass:Class<T>):Void
	{
		context.components.remove(this, componentClass);
	}
	
	public function has<T>(componentClass:Class<T>):Bool
	{
		return context.components.has(this, componentClass);
	}
	
	public function clear():Void
	{
		context.components.clear(this);
	}
	
	public function destroy():Void
	{
		context.entities.destroy(this);
	}
	
	@:keep
	private function hxSerialize(serializer:Serializer):Void
	{
		serializer.serialize(id);
	}
	
	@:keep
	private function hxUnserialize(unserializer:Unserializer):Void
	{
		id = unserializer.unserialize();
	}
	
}
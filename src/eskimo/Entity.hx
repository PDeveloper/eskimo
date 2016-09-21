package eskimo;
import eskimo.bits.BitFlag;
import haxe.Serializer;
import haxe.Unserializer;

/**
 * ...
 * @author PDeveloper
 */

class Entity
{
	
	private var entities:EntityManager;
	public var id:Int;
	
	public var flag:BitFlag;
	
	public inline function new(entities:EntityManager, id:Int):Void
	{
		this.entities = entities;
		this.id = id;
		
		this.flag = new BitFlag();
	}
	
	public inline function set<T>(component:T):Void
	{
		entities.components.set(this, component);
	}
	
	public inline function get<T>(componentClass:Class<T>):T
	{
		return entities.components.get(this, componentClass);
	}
	
	public inline function remove<T>(componentClass:Class<T>):Void
	{
		entities.components.remove(this, componentClass);
	}
	
	public inline function has<T>(componentClass:Class<T>):Bool
	{
		return entities.components.has(this, componentClass);
	}
	
	public inline function clear():Void
	{
		entities.components.clear(this);
	}
	
	public inline function destroy():Void
	{
		entities.destroy(this);
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
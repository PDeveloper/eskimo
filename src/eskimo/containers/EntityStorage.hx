package eskimo.containers;
import eskimo.Entity;

/**
 * ...
 * @author PDeveloper
 */

abstract EntityStorage<T>(Array<T>) from Array<T>
{
	
	@:arrayAccess
	public inline function get(idx:Entity):T {
		return this[idx.id()];
	}
	
	@:arrayAccess
	public inline function set(idx:Entity, item:T):Void {
		this[idx.id()] = item;
	}
	
}
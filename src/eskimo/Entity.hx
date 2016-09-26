package eskimo;

/**
 * ...
 * @author PDeveloper
 */

abstract Entity(Int)
{
	@:allow(eskimo.EntityManager)
	inline function new(id:Int):Void
	{
		this = id;
	}
	
	public inline function id():Int return this;
}
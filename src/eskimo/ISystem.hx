package eskimo;

/**
 * ...
 * @author PDeveloper
 */

interface ISystem
{
	
	public function onAdd(context:Context):Void;
	public function update(dt:Float):Void;
	public function onRemove(context:Context):Void;
	
}
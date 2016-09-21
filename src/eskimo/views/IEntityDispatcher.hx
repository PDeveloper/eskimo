package eskimo.views;

/**
 * @author PDeveloper
 */

interface IEntityDispatcher 
{
	
	public function listen(listener:IEntityListener):Void;
	public function unlisten(listener:IEntityListener):Void;
	
}
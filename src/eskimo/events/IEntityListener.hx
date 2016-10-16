package eskimo.events;
import eskimo.ComponentManager.IComponentType;
import eskimo.Entity;

/**
 * @author PDeveloper
 */

interface IEntityListener 
{
	
	public function onAdd(e:Entity):Void;
	public function onUpdate(e:Entity, type:IComponentType):Void;
	public function onRemove(e:Entity):Void;
	
}
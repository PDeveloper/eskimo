package eskimo.containers;
import eskimo.ComponentManager.IComponentType;
import eskimo.Entity;

/**
 * @author PDeveloper
 */

interface IContainerListener 
{
	
	public function update(e:Entity, type:IComponentType):Void;
	
}
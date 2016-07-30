package;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.EntityManager;
import eskimo.systems.SystemManager;
import eskimo.views.BufferView;
import eskimo.views.EventView;
import eskimo.views.View;
import haxe.Json;

import Components;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class Main 
{
	
	static function main():Void
	{
		trace('Entity API Tests');
		
		var components = new ComponentManager();
		var entities = new EntityManager(components);
		
		var e0 = entities.create();
		var e1 = entities.create();
		
		var c0a = new ComponentA('Entity 0 :: Component A');
		var c0b = new ComponentB(7);
		
		var c1b = new ComponentB(13);
		var c1c = new ComponentC( { name: 'Entity 1', value: 1 } );
		
		components.set(e0, c0a);
		components.set(e0, c0b);
		
		components.set(e1, c1b);
		components.set(e1, c1c);
		
		if (components.get(e0, ComponentA).string == 'Entity 0 :: Component A' &&
			components.get(e0, ComponentB).int == 7 &&
			components.get(e1, ComponentB).int == 13 &&
			Json.stringify(components.get(e1, ComponentC).object) == Json.stringify( { name: 'Entity 1', value: 1 } ))
		{
			trace('Test 1 Succeeded :: Correct component storage');
		}
		else
		{
			trace('Test 1 Failed:');
			trace('Entity 0 / Component A: ${components.get(e0, ComponentA).string}');
			trace('Entity 0 / Component B: ${components.get(e0, ComponentB).int}');
			trace('Entity 1 / Component B: ${components.get(e1, ComponentB).int}');
			trace('Entity 1 / Component C: ${components.get(e1, ComponentC).object}');
		}
		
		var viewab = new View([ComponentA, ComponentB], entities);
		var viewb = new View([ComponentB], entities);
		
		viewab.onAdd = function (entity:Entity):Void
		{
			trace('${entity.id} was added to viewab');
		}
		
		if (viewab.entities.length == 1 &&
			viewb.entities.length == 2)
		{
			trace('Test 2 Succeeded :: Views correctly initialized');
		}
		else
		{
			trace('Test 2 Failed:');
			trace('AB Entities: ${viewab.entities.length}');
			trace('B Entities: ${viewb.entities.length}');
		}
		
		var c1a = new ComponentA('Entity 1 :: Component A');
		e1.set(c1a);
		
		if (viewab.entities.length == 2 &&
			viewb.entities.length == 2)
		{
			trace('Test 3 Succeeded :: Views correctly respond to entity changes');
		}
		else
		{
			trace('Test 3 Failed:');
			trace('AB Entities: ${viewab.entities.length}');
			trace('B Entities: ${viewb.entities.length}');
		}
		
		var eventviewab = new EventView([ComponentA, ComponentB], entities);
		
		if (eventviewab.added.length == 2)
		{
			trace('Test 4 Succeeded :: EventView picks up added entities');
		}
		else
		{
			trace('Test 4 Failed:');
			trace('Added: ${eventviewab.added.length}');
		}
		
		e1.remove(ComponentA);
		
		if (eventviewab.removed.length == 1)
		{
			trace('Test 5 Succeeded :: EventView picks up removed entities');
		}
		else
		{
			trace('Test 5 Failed:');
			trace('Removed: ${eventviewab.removed.length}');
		}
		
		eventviewab.clear();
		
		if (eventviewab.added.length == 0 &&
			eventviewab.updated.length == 0 &&
			eventviewab.removed.length == 0)
		{
			trace('Test 6 Succeeded :: EventView clears events');
		}
		else
		{
			trace('Test 6 Failed:');
			trace('Added: ${eventviewab.added.length}');
			trace('Updated: ${eventviewab.updated.length}');
			trace('Removed: ${eventviewab.removed.length}');
		}
		
		var bufferviewa = new BufferView([ComponentA], entities);
		
		var c0a2 = new ComponentA('Entity 0 :: Component A 2');
		
		e0.set(c0a2);
		
		var c0a_current_value = e0.get(ComponentA).string;
		var c0a_previous_value = bufferviewa.previous(e0, ComponentA).string;
		bufferviewa.buffer();
		var c0a_buffered_value = bufferviewa.previous(e0, ComponentA).string;
		
		if (c0a_previous_value == c0a.string &&
			c0a_current_value == c0a_buffered_value)
		{
			trace('Test 7 Succeeded :: BufferView buffers previous entity components');
		}
		else
		{
			trace('Test 7 Failed:');
			trace('Current Value: $c0a_current_value');
			trace('Previous Value: $c0a_previous_value');
			trace('Buffered Value (should match Current Value): $c0a_buffered_value');
		}
		
		trace('Systems API Tests');
		
		var systems = new SystemManager(entities);
		
		var systemA = new SystemA();
		var systemB = new SystemB();
		var systemC = new SystemC();
		
		systems.add(systemB);
		
		if (!systemB.isActive()) trace('Test 1 Succeeded :: SystemB is added but inactive');
		else trace('Test 1 Failed :: SystemB is added and became active');
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.add(systemA);
		
		if (systemA.isActive() && systemB.isActive()) trace('Test 2 Succeeded :: SystemA was added and active, and SystemB became active');
		else
		{
			trace('Test 2 Failed :: SystemA was added but not all systems became active');
			trace('SystemA: ${systemA.isActive()}, SystemB: ${systemB.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.add(systemC);
		
		if (systemA.isActive() && systemB.isActive() && systemC.isActive()) trace('Test 3 Succeeded :: SystemC was added and became active');
		else
		{
			trace('Test 3 Failed :: SystemC was added but not all systems became active');
			trace('SystemA: ${systemA.isActive()}, SystemB: ${systemB.isActive()}, SystemC: ${systemC.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
		
		systems.remove(systemA);
		
		if (!systemB.isActive() && !systemC.isActive()) trace('Test 4 Succeeded :: SystemA was removed, all systems became inactive');
		else
		{
			trace('Test 4 Failed :: SystemA was removed, but some systems were still active');
			trace('SystemB: ${systemB.isActive()}, SystemC: ${systemC.isActive()}');
		}
		
		trace('System Update Start');
		systems.update(0.0);
		trace('System Update Finish');
	}
	
}
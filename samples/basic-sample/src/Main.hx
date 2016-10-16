package;
import eskimo.ComponentManager;
import eskimo.Entity;
import eskimo.EntityManager;
import eskimo.events.ViewEvents;
import eskimo.core.Factory;
import eskimo.core.View;
import haxe.Json;

import Components;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class Main 
{
	
	static var factoryabc = new Factory<ComponentA, ComponentB, ComponentC>();
	
	static var viewab = new View<ComponentA, ComponentB>();
	static var viewb = new View<ComponentB>();
	
	static function main():Void
	{
		var components = new ComponentManager();
		var entities = new EntityManager(components);
		
		factoryabc.initialize(entities);
		
		var e0 = factoryabc.create();
		var e1 = factoryabc.create();
		
		var c0a = new ComponentA('Entity 0 :: Component A');
		var c0b = new ComponentB(7);
		
		var c1b = new ComponentB(13);
		var c1c = new ComponentC( { name: 'Entity 1', value: 1 } );
		
		e0.componentA = c0a;
		e0.componentB = c0b;
		
		e1.componentB = c1b;
		e1.componentC = c1c;
		
		if (factoryabc.getComponentA(e0.get()).string == 'Entity 0 :: Component A' &&
			factoryabc.getComponentB(e0.get()).int == 7 &&
			factoryabc.getComponentB(e1.get()).int == 13 &&
			Json.stringify(factoryabc.getComponentC(e1.get()).object) == Json.stringify( { name: 'Entity 1', value: 1 } ))
		{
			trace('Test 1 Succeeded :: Correct component storage');
		}
		else
		{
			trace('Test 1 Failed:');
			trace('Entity 0 / Component A: ${components.get(e0.get(), ComponentA).string}');
			trace('Entity 0 / Component B: ${components.get(e0.get(), ComponentB).int}');
			trace('Entity 1 / Component B: ${components.get(e1.get(), ComponentB).int}');
			trace('Entity 1 / Component C: ${components.get(e1.get(), ComponentC).object}');
		}
		
		var eventviewab = new ViewEvents(viewab.dispatcher);
		viewab.initialize(entities);
		viewb.initialize(entities);
		
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
		e1.componentA = c1a;
		
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
		
		if (eventviewab.added.length == 2)
		{
			trace('Test 4 Succeeded :: EventView picks up added entities');
		}
		else
		{
			trace('Test 4 Failed:');
			trace('Added: ${eventviewab.added.length}');
		}
		
		e1.componentA = null;
		
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
	}
	
}
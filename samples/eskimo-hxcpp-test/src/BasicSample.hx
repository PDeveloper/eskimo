package;
import eskimo.BufferView;
import eskimo.Context;
import eskimo.EventView;
import eskimo.View;
import haxe.Json;

import Components;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class BasicSample
{

	public function new():Void
	{
	}
	
	public function run():Void
	{
		var context = new Context();
		
		var e0 = context.entities.create();
		var e1 = context.entities.create();
		
		var c0a = new ComponentA('Entity 0 :: Component A');
		var c0b = new ComponentB(7);
		
		var c1b = new ComponentB(13);
		var c1c = new ComponentC( { name: 'Entity 1', value: 1 } );
		
		context.components.set(e0, c0a);
		context.components.set(e0, c0b);
		
		context.components.set(e1, c1b);
		context.components.set(e1, c1c);
		
		if (context.components.get(e0, ComponentA).string == 'Entity 0 :: Component A' &&
			context.components.get(e0, ComponentB).int == 7 &&
			context.components.get(e1, ComponentB).int == 13 &&
			Json.stringify(context.components.get(e1, ComponentC).object) == Json.stringify( { name: 'Entity 1', value: 1 } ))
		{
			trace('Test 1 Succeeded :: Correct component storage');
		}
		else
		{
			trace('Test 1 Failed:');
			trace('Entity 0 / Component A: ${context.components.get(e0, ComponentA).string}');
			trace('Entity 0 / Component B: ${context.components.get(e0, ComponentB).int}');
			trace('Entity 1 / Component B: ${context.components.get(e1, ComponentB).int}');
			trace('Entity 1 / Component C: ${context.components.get(e1, ComponentC).object}');
		}
		
		var viewab = new View([ComponentA, ComponentB], context);
		var viewb = new View([ComponentB], context);
		
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
		
		var eventviewab = new EventView([ComponentA, ComponentB], context);
		
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
		
		var bufferviewa = new BufferView([ComponentA], context);
		
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
	}
	
}
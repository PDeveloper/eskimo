package;

import cpp.Lib;
import haxe.Json;
import eskimo.Context;
import eskimo.ISystem;
import eskimo.View;

/**
 * ...
 * @author PDeveloper
 */

using Lambda;

class ComponentA
{
	public var string:String;
	
	public function new(string:String):Void
	{
		this.string = string;
	}
}

class ComponentB
{
	public var int:Int;
	
	public function new(int:Int):Void
	{
		this.int = int;
	}
}

class ComponentC
{
	public var object:Dynamic;
	
	public function new(object:Dynamic):Void
	{
		this.object = object;
	}
}

class SystemA implements ISystem
{
	
	private var view1:View = new View([ComponentA, ComponentB]);
	
	public function new():Void
	{
		
	}
	
	public function onAdd(context:Context):Void
	{
		view1.initialize(context);
	}
	
	public function update(dt:Float):Void
	{
		
	}
	
	public function onRemove(context:Context):Void
	{
		view1.destroy();
	}
	
}

class Main 
{
	
	static function main():Void
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
			trace(context.components.get(e0, ComponentA).string);
			trace(context.components.get(e0, ComponentB).int);
			trace(context.components.get(e1, ComponentB).int);
			trace(context.components.get(e1, ComponentC).object);
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
			trace(viewab.entities.length);
			trace(viewb.entities.length);
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
			trace(viewab.entities.length);
			trace(viewb.entities.length);
		}
		
		var system0 = new SystemA();
	}
	
}
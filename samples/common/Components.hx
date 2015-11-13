package;

/**
 * ...
 * @author PDeveloper
 */

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
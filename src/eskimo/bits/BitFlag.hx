package eskimo.bits;
import haxe.Int64;

using haxe.Int64;

/**
 * ...
 * @author PDeveloper
 */

class BitFlag
{
	
	public static var EMPTY:BitFlag = new BitFlag();
	
	private var bits0:Int;
	private var bits1:Int;
	private var bits2:Int;
	private var bits3:Int;
	
	public function new()
	{	
		bits0 = 0;
		bits1 = 0;
		bits2 = 0;
		bits3 = 0;
	}
	
	public inline function set(bit:Int, value:Int):Void
	{
		if (bit < 33) bits0 |= value << (bit - 1);
		else if (bit < 65) bits1 |= value << (bit - 33);
		else if (bit < 97) bits2 |= value << (bit - 65);
		else bits3 |= value << (bit - 97);
	}
	
	public inline function setTrue(bit:Int):Void
	{
		if (bit < 33) bits0 |= 1 << (bit - 1);
		else if (bit < 65) bits1 |= 1 << (bit - 33);
		else if (bit < 97) bits2 |= 1 << (bit - 65);
		else bits3 |= 1 << (bit - 97);
	}
	
	public inline function setFalse(bit:Int):Void
	{
		if (bit < 33) bits0 &= ~(1 << (bit - 1 ));
		else if (bit < 65) bits1 &= ~(1 << (bit - 33));
		else if (bit < 97) bits2 &= ~(1 << (bit - 65));
		else bits3 &= ~(1 << (bit - 97));
	}
	
	public inline function get(bit:Int, length:Int = 1):Int
	{
		if (bit < 33) return (bits0 >> (bit - 1)) & length;
		else if (bit < 65) return (bits1 >> ( bit - 33)) & length;
		else if (bit < 97) return (bits2 >> (bit - 65)) & length;
		else return (bits3 >> (bit - 97)) & length;
	}
	
	public function add(flag:BitFlag):BitFlag
	{
		bits0 |= flag.bits0;
		bits1 |= flag.bits1;
		bits2 |= flag.bits2;
		bits3 |= flag.bits3;
		return this;
	}
	
	public function sub(flag:BitFlag):BitFlag
	{
		bits0 &= ~flag.bits0;
		bits1 &= ~flag.bits1;
		bits2 &= ~flag.bits2;
		bits3 &= ~flag.bits3;
		
		return this;
	}
	
	public function equals(flag:BitFlag):Bool
	{
		return bits0 == flag.bits0 &&
				bits1 == flag.bits1 &&
				bits2 == flag.bits2 &&
				bits3 == flag.bits3;
	}
	
	public inline function contains(flag:BitFlag):Bool
	{
		if (bits0 & flag.bits0 == flag.bits0 &&
			bits1 & flag.bits1 == flag.bits1 &&
			bits2 & flag.bits2 == flag.bits2 &&
			bits3 & flag.bits3 == flag.bits3) return true;
		
		return false;
	}
	
	public function flip():Void
	{
		bits0 = ~bits0;
		bits1 = ~bits1;
		bits2 = ~bits2;
		bits3 = ~bits3;
	}
	
	public function clear():Void
	{
		bits0 =
		bits1 =
		bits2 =
		bits3 = 0;
	}
	
	public function toString():String
	{
		var output = "";
		
		for (i in 0...32) output = Std.string((bits0 >> i) & 1) + output;
		for (i in 0...32) output = Std.string((bits1 >> i) & 1) + output;
		for (i in 0...32) output = Std.string((bits2 >> i) & 1) + output;
		for (i in 0...32) output = Std.string((bits3 >> i) & 1) + output;
		
		return output;
	}
	
}
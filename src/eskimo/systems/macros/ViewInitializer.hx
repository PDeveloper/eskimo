package eskimo.systems.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author PDeveloper
 */

using haxe.macro.Tools;

class ViewInitializer
{
	
	macro static public function build2():Array<Field>
	{
        var fields = Context.getBuildFields();
		return fields;
	}
	
	macro static public function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		return fields;
	}
	
}
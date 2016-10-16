package eskimo.tools;
import eskimo.EntityManager;

#if macro
import eskimo.macros.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type.ClassField;

/**
 * ...
 * @author PDeveloper
 */

using haxe.macro.Tools;
#end

class FactoryTools
{
	
	#if macro
	macro static public function createFactories(entities:ExprOf<eskimo.EntityManager>):Expr
	{
		var localClass = Context.getLocalClass().get();
		var fields = localClass.fields.get();
		
		var exprs:Array<Expr> = [];
		
		for (field in fields) {
			switch (field.type) {
				case TInst(_.get() => type, types):
					if (TypeTools.subclasses(type, 'eskimo.core.Factory_'))
					{
						var view_create_expr:Expr = {expr: ENew({
							pack: type.pack,
							name: type.name,
							params: []
						}, [macro $entities]), pos: Context.currentPos() };
						
						exprs.push(macro $i{field.name} = $view_create_expr);
					}
				default: var void:String;
			}
		}
		
		return macro $b{exprs};
	}
	#else
	macro static public inline function createFactories(entities:ExprOf<eskimo.EntityManager>):Void {}
	#end
	
}